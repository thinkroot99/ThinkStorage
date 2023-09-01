#!/bin/bash

# Script pentru monitorizarea spațiului liber pe partiții și trimiterea de notificări pe e-mail

# Pentru a folosi acest script:
# 1. Asigură-te că ai instalate utilitarele 'mailx' sau 'sendmail' pentru trimiterea de e-mail-uri.
#    - Pe Ubuntu/Debian: sudo apt-get install mailutils
#    - Pe Fedora: sudo dnf install mailix
#    - Pe Arch Linux: sudo pacman -S mailx
#    - Pe openSUSE: sudo zypper install mailx
# 2. Completează informațiile de e-mail și serverul SMTP în variabilele de mai jos.
# 3. Dă permisiuni de executare scriptului: chmod +x ThinkTemp.sh
# 4. Poți rula scriptul manual pentru test: ./ThinkTemp.sh
# 5. Pentru a rula scriptul automat, poți să-l adaugi în crontab sau să-l configurezi cu systemd.

# Adresa de e-mail pentru notificări
EMAIL="adresa_ta@example.com"
# Numele serverului SMTP
SMTP_SERVER="server.smtp.com"
# Portul SMTP
SMTP_PORT="587"
# Utilizatorul pentru autentificarea SMTP
SMTP_USER="utilizator"
# Parola pentru autentificarea SMTP
SMTP_PASSWORD="parola"
# Lmita pentru trimiterea de notificări (%)
ALERT_THRESHOLD=80


# Funcțîe pentru verificarea spațiului ocupat
check_disk_space() {
  echo "Verificarea spațiului pe partiții..."
  df -h | tail -n +2 | while read line; do
    partition=$(echo $line | awk '{print $1}')
    used_space=$(echo $line | awk '{print $3}')
    available_space=$(echo $line | awk '{print $4}')
    used_percent=$(echo $line | awk '{print $5}' | sed 's/%//')
    
    if [ $used_percent -ge $ALERT_THRESHOLD ]; then
      send_notification "$partition" "$used_space" "$available_space" "$used_percent"
    fi
  done
}

# Funcție pentru trimiterea de notificări pe e-mail
send_notification() {
  partition="$1"
  used_space="$2"
  available_space="$3"
  used_percent="$4"
  
  subject="Alertă spațiu pe partiție $partition"
  message="Spațiul pe partiția $partition a ajuns la $used_percent% ocupat.\n\nDetalii:\nSpațiul utilizat: $used_space\nSpațiul disponibil: $available_space"

  echo -e "$message" | \
    mailx -s "$subject" -S smtp="$SMTP_SERVER:$SMTP_PORT" \
    -S smtp-use-starttls -S smtp-auth=login -S smtp-auth-user="$SMTP_USER" \
    -S smtp-auth-password="$SMTP_PASSWORD" -S ssl-verify=ignore "$EMAIL"

  echo "Notificare trimisă pentru $partition ($used_percent% ocupat)"
}
# Rulează verificarea la fiecare 30 de minute
while true; do
  check_disk_space
  sleep 1800
done

# ...

# Adaugarea la crontab pentru rulare la fiecare 30 de minute:
# Deschide terminalul și rulează 'crontab -e' pentru a edita crontab-ul
# Adaugă linia de mai jos și salvează:
# */30 * * * * /calea/catre/disk_space_monitor.sh

# Adăugarea la systemd pentru rulare ca serviciu:
# 1. Copiază scriptul într-un director dedicat, de exemplu: /usr/local/bin/
# 2. Creează un fișier de serviciu, de exemplu: /etc/systemd/system/disk-space-monitor.service

# Conținutul fișierului disk-space-monitor.service:
# [Unit]
# Description=Monitorizare spațiu pe partiții

# [Service]
# ExecStart=/usr/local/bin/disk_space_monitor.sh

# [Install]
# WantedBy=multi-user.target

# 3. Rulează comenzile:
# sudo systemctl daemon-reload
# sudo systemctl enable disk-space-monitor.service
# sudo systemctl start disk-space-monitor.service
