# frozen_string_literal: true

def amanda_user
  (fact('os.family') == 'Debian') ? 'backup' : 'amandabackup'
end

def amanda_homedir
  (fact('os.family') == 'Debian') ? '/var/backups' : '/var/lib/amanda'
end
