import sys
import threading
import queue

#############################
# Cross-platform keyboard listener
#############################
#
# Start this class from a new thread and poll get_key()
#   to return key presses in order (or None)
#

class KeyListener(threading.Thread):
    def __init__(self):
        super().__init__(daemon=True)
        self._key_queue = queue.Queue()
        self._stop_event = threading.Event()

        if not sys.platform.startswith("win"):
            import termios, tty, select
            self.termios = termios
            self.tty = tty
            self.select = select
            self.stdin_fd = sys.stdin.fileno()
            self.old_settings = termios.tcgetattr(self.stdin_fd)
            tty.setcbreak(self.stdin_fd)

    def run(self):
        if sys.platform.startswith("win"):
            import msvcrt
            while not self._stop_event.is_set():
                if msvcrt.kbhit():
                    key = msvcrt.getch()
                    try:
                        self._key_queue.put_nowait(key.decode("utf-8"))
                    except UnicodeDecodeError:
                        pass
                time.sleep(0.05)
        else:
            while not self._stop_event.is_set():
                rlist, _, _ = self.select.select([sys.stdin], [], [], 0.05)
                if rlist:
                    key = sys.stdin.read(1)
                    self._key_queue.put_nowait(key)

    def get_key(self):
        try:
            return self._key_queue.get_nowait()
        except queue.Empty:
            return None

    def stop(self):
        self._stop_event.set()
        if not sys.platform.startswith("win"):
            self.termios.tcsetattr(self.stdin_fd, self.termios.TCSADRAIN, self.old_settings)

