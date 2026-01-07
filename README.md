# SAE34
Infrastructure Virtualisée

Contexte : Vous êtes technicien réseau chez un opérateur.
Mission : Prototyper une stack de services réseau conteneurisés (Docker) destinée à être déployée en production sur des routeurs (MikroTik) ou des serveurs de POP.

En SAÉ (Aujourd'hui) : Tout se passe sur votre machine.
● Côté Serveur : Docker héberge l'infrastructure (NTP, DNS, Radius, DB).
● Côté Client : Votre propre OS (Windows/Linux) ou des outils de test (nslookup, radtest) simuleront les requêtes du réseau.


Rôles dans la SAE : 
● L'Intégrateur (A) : Le garant du docker-compose.yml, du VPN et du réseau.
● L'Admin Services (B) : Le responsable du DNS et du NTP.
● L'Admin Backend (C) : Le responsable du couple FreeRADIUS/ PostgreSQL


Services :

● NTP :
  - Rôle :  Garantir une horloge unique pour la corrélation des logs et la validité des certificats, les routeurs clients et tous les équipements nécessaire.
  - Challenge Technique : Un conteneur ne peut pas changer l'heure du noyau hôte par défaut. Il doit agir en relais.
  - Logiciel suggéré : Chrony. --> NTP/chrony.conf
  - Test de validation : ntpdate -q 127.0.0.1

● DNS :
  - Rôle : Resolver (Cache pour accélérer le web) + Zone Locale optionnelle (Authoritative pour sae34.lan)
  - Logiciel suggéré : BIND9.
  - Ports : Attention, le DNS utilise UDP/53 (standard) et TCP/53 (réponses > 512 octets ou transferts de zone).
  - Test de validation : dig @127.0.0.1 -p 53 google.fr

● VPN :
  - Rôle : Permettre à un administrateur de se connecter au réseau de gestion de manière chiffrée.
  - Spécificité Docker : Le conteneur a besoin de privilèges élevés (NET_ADMIN) pour créer l'interface réseau virtuelle (tun0).
  - Logiciel : OpenVPN
  - Test de validation : nc -u -v -z 127.0.0.1 1194

● AAA :
  - Rôle : Authentifier les utilisateurs (Radius) et stocker leurs données (PostgreSQL).
  - Architecture Micro-Services :
    a. Conteneur A (Cerveau) : FreeRADIUS.
    b. Conteneur B (Mémoire) : PostgreSQL
  - Le Piège : FreeRADIUS ne doit pas chercher la base de données sur localhost (sa propre machine virtuelle), mais sur le nom DNS du conteneur DB via le réseau Docker.
  - Test de validation : radtest user pass 127.0.0.1 1812 secret


Docker : 
test