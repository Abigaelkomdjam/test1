cat > "main (2).py" << 'EOF'
# main (2).py - Fichier de test avec erreurs mypy et pylint

def greet(name):
    return "Hello " + name  # Erreur: name n'a pas de type

x: int = "123"  # Erreur: str assigné à int

y: list = [1, "deux", 3.0]  # Erreur: list sans type précis

print(greet(42))  # Erreur: int au lieu de str

# Ligne longue pour pylint
print("Cette ligne fait plus de 100 caractères pour déclencher une erreur pylint et tester le linting complet du système de qualité.")

def unused_function():
    pass  # Erreur pylint: fonction non utilisée
EOF