import sys
from pathlib import Path

# Make main.py and tools.py importable when pytest runs from the app folder.
sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
