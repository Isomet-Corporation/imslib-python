import imslib

class iMSScanner:
    def __init__(self, settings=None):
        self.conn = imslib.ConnectionList()
        if isinstance(settings, dict):
            for k, v in settings.items():
                self.conn.Settings(k, v)
        self.ims = None

    def scan(self, auto_select=False, match_port=None, index=None):
        print("Scanning for iMS Systems . . .")
        systems = self.conn.Scan()

        if len(systems) == 0:
            print("No systems found.")
            return False

        if auto_select:
            # Select by index if provided
            if index is not None:
                if 0 <= index < len(systems):
                    self.ims = systems[index]
                else:
                    print(f"Index {index} is out of range.")
                    return False

            # Select by port name if provided
            elif match_port is not None:
                for s in systems:
                    if match_port in s.ConnPort():
                        self.ims = s
                        break
                if self.ims is None:
                    print(f"No system matching port '{match_port}' found.")
                    return False

            # Default to first system
            else:
                self.ims = systems[0]

            print("Auto-selected iMS System:", self.ims.ConnPort())
            return True

        # Interactive mode
        for i, ims in enumerate(systems):
            print(f" {i+1}: {ims.ConnPort()}")

        choice = 0
        while choice == 0:
            choice_str = input("Select an iMS System: ").strip()
            try:
                choice = int(choice_str)
            except ValueError:
                choice = 0
            if choice > len(systems) or choice < 1:
                choice = 0

        self.ims = systems[choice - 1]
        print()
        print("Using iMS System:", self.ims.ConnPort())
        return True

    def scan_interface(self, interface, address_hints=None, auto_select=True):
        """
        Scan a single interface for iMS systems.

        Args:
            interface (str): Interface name, e.g. "usb0" or "eth1".
            address_hints (list[str], optional): Address or range strings to limit the scan.
            auto_select (bool): If True, automatically select the first found system.

        Returns:
            bool: True if a system was found and selected, False otherwise.
        """
        address_hints = address_hints or []
        print(f"Scanning interface '{interface}' . . .")

        sys = self.conn.Scan(interface, address_hints)
        if sys:
            if auto_select:
                self.ims = sys
                print("Found iMS System:", sys.ConnPort())
            return True
        else:
            print("No system found on interface:", interface)
            return False

    def find(self, interface, system_id, address_hints=None):
        """
        Find a specific iMS system by ID.

        Args:
            interface (str): Interface name, e.g. "usb0".
            system_id (str): Target system ID (matches IMSSystem.ConnPort()).
            address_hints (list[str], optional): Address or range strings to narrow the search.

        Returns:
            bool: True if found and selected, False otherwise.
        """
        address_hints = address_hints or []
        print(f"Searching for system '{system_id}' on '{interface}' . . .")

        sys = self.conn.Find(interface, system_id, address_hints)
        if sys:
            self.ims = sys
            print("Found and selected system:", sys.ConnPort())
            return True
        else:
            print("System not found.")
            return False
        
    def get_system(self):
        return self.ims

