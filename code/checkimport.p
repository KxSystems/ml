p)def< checkimport():
  import subprocess
  import sys
  reqs = subprocess.check_output([sys.executable, '-m', 'pip', 'freeze'])
  installed_packages = [r.decode().split('==')[0] for r in reqs.split()]
  return(installed_packages)
