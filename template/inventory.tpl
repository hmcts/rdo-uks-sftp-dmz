[windows]
${public_ip}

[dmz]
${public_ip}

[windows:vars]
ansible_user=${username}
ansible_password=${admin_pass}
ansible_connection=winrm
ansible_port=5986
ansible_winrm_transport=basic
ansible_winrm_server_cert_validation=ignore