

choco install apache-httpd --params '"/serviceName:daswebserver /installLocation:D:\Server\apache-httpd /port:80"' -Force

choco install php --package-parameters='"/ThreadSafe /InstallDir:D:\Server\php"' -Force