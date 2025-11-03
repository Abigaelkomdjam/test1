# main.py
def greet(name):
    return "Hello " + name  # Erreur mypy : str + ??? → Any

x: int = "123"  # Erreur mypy : str assigné à int

print(greet(42))  # Erreur mypy : int au lieu de str