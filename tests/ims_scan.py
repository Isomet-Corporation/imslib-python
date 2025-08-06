import imslib

class iMSScanner:
    def __init__(self):
        self.conn = imslib.ConnectionList()
        self.ims = None

    def scan(self, auto_select=False, match_port=None, index=None):
        print("Scanning for iMS Systems . . .")
        systems = self.conn.scan()

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

    def get_system(self):
        return self.ims

