# Setting Up a Local HTTPS Certificate Authority

If you need to enable HTTPS for your local testing environment, you can utilize the provided script. Alternatively, you can also explore [mkcert](https://github.com/FiloSottile/mkcert) for this purpose.

## Usage

```bash
./my_mkcert.sh mynewdomain.loc
```

This script will generate files within `$HOME/certs/sites`, which you can then incorporate into a VirtualHost configuration, as illustrated below:

```config
<VirtualHost *:443>
   ServerName mynewdomain.loc
   DocumentRoot /var/www/MONSITE

   SSLEngine on
   SSLCertificateFile /path/to/certs/mynewdomain.loc.crt
   SSLCertificateKeyFile /path/to/certs/mynewdomain.loc.key
</VirtualHost>
```

## Important Note

Upon first execution, the script will generate a private key to establish a local Certificate Authority (CA) and a root certificate, both saved in the $HOME/certs directory.

Additionally, on Arch Linux systems, the script will automatically add the generated certificate to the system-wide trusted store.

## Resources

https://deliciousbrains.com/ssl-certificate-authority-for-local-https-development/
https://wiki.archlinux.org/title/User:Grawity/Adding_a_trusted_CA_certificate
