# main (2).py - Fichier de test avec erreurs mypy et pylint

def greet(name):
    return "Hello " + name  # Erreur mypy: pas de type

x: int = "123"  # Erreur mypy: str au lieu de int

y: list = [1, "deux", 3.0]  # Erreur mypy: list[Any], pas typé

print(greet(42))  # Erreur mypy: int au lieu de str

# Ligne trop longue pour pylint
print("Cette ligne fait plus de 100 caractères pour déclencher une erreur pylint et tester le linting complet du système de qualité.")

def unused_function():
    pass  # Erreur pylint: fonction non utilisée
bad: str = 999

# Erreur test Gemini
wrong: int = 'test'  # mypy va râler

