import imslib
import threading
import queue
from typing import Iterable, Tuple, Any, Dict, Optional

class EventWaiter(imslib.IEventHandler):
    """
    Thread-safe event waiter that can filter by message and optionally by sender.
    """

    def __init__(self):
        super().__init__() 
        self._watched = set()        # Message IDs to listen for
        self._queue = queue.Queue()  # Incoming events
        self._lock = threading.Lock()

    def listen_for(self, messages: Iterable[int], sender: Optional[object] = None):
        """
        Register message IDs to listen for.
        Optional: filter events by sender instance.
        """
        with self._lock:
            self._watched.update(messages)

    def EventAction(self, sender, message, *args):
        """
        Called from library; enqueue if message is watched and sender matches.
        """
        with self._lock:
            if message in self._watched:
                self._queue.put((message, args))

    def wait(self, timeout: float = None) -> Tuple[object, int, Any]:
        """
        Block until a watched event arrives.
        Returns (sender, message_id, args) if received.
        Raises TimeoutError if no event occurs before timeout.
        """
        try:
            return self._queue.get(timeout=timeout)
        except queue.Empty:
            with self._lock:
                watched_copy = list(self._watched)
            raise TimeoutError(f"Timeout waiting for any of {watched_copy}")



""" An example function that demonstrates usage of EventWaiter. Prints a user supplied string when events fire """
def WaitOnEventsThenPrint(waiter: EventWaiter, event_messages: Dict[int, str], timeout: float = 10.0):
    """
    Waits for events from the waiter and prints friendly messages.

    Args:
        waiter: EventWaiter instance already subscribed to the events.
        event_messages: Dictionary mapping DownloadEvents.* to friendly strings.
        timeout: How long to wait for the first event.
    """
    try:
        msg, params = waiter.wait(timeout=timeout)
        friendly_msg = event_messages.get(msg, f"Unknown event {msg}")
        print(f"Event : {friendly_msg}, params: {params}")

    except TimeoutError:
        print("⏱️ Timed out waiting for events.")