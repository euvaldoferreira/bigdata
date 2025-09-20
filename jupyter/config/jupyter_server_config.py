# Configuração do Jupyter Lab

c = get_config()

# Configurações básicas
c.ServerApp.ip = '0.0.0.0'
c.ServerApp.port = 8888
c.ServerApp.open_browser = False
c.ServerApp.allow_root = True
c.ServerApp.token = ''
c.ServerApp.password = ''

# Diretório de trabalho
c.ServerApp.root_dir = '/home/jovyan/work'

# Configurações de segurança
c.ServerApp.allow_origin = '*'
c.ServerApp.disable_check_xsrf = True

# Configurações do kernel
c.KernelManager.shutdown_wait_time = 30.0

# Extensões
c.LabServerApp.extra_labextensions_path = []

# Logging
c.Application.log_level = 'INFO'