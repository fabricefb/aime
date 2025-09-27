# Générer une paire de clés SSH si vous n'en avez pas déjà
ssh-keygen -t ed25519 -C "votre@email.com"

# Copier la clé publique sur le serveur cPanel
ssh-copy-id -i /workspaces/aime/.ssh/aime_deploy_key cp2639565p41@aime-rdc.org

# Tester la connexion SSH
ssh -i /workspaces/aime/.ssh/aime_deploy_key cp2639565p41@aime-rdc.org "echo 'Connexion SSH réussie!'"