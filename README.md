<img src="https://convergence.io/assets/img/convergence-logo.png" height="50" />

# Convergence Omnibus Container
The Convergence Omnibus Container is an all-in-one version of [Convergence](https://convergence.io) which is useful for developers to use when developing Convergence based applications. It is also useful for simple, or small installations that do not require high availability.

It contains the Convergence Server, the Convergence Admin Console, the Convergence Client, and an OrientDB Database.

For documentation, code samples, and information on Convergence Enterprise Edition (suitable for production use cases), please visit: [https://convergence.io](https://convergence.io)

## Basic Usage
To run, simply execute the following docker run command:

```shell script
docker run -p "8000:80" convergencelabs/convergence-omnibus
```

### URLS
Once started serveral servrices will be available under `http://localhost:8000/` (replace port and hostname as required):
- The Convergence Admin Console will be available at: `http://localhost:8000/`.
- The REST API will be available at: `http://localhost:8000/rest/`.
- The Realtime API will be available at: `http://localhost:8000/realtime/`. 
- The JavaScript API Documnetation will be available at `http://localhost:8000/api/`.  
- The various client builds will available at `http://localhost:8000/client/`.

### Default Credentials
A default Server Admin user will be created when the container first starts up.  The default credentials are `admin` / `password`. These credentials can be changed via environment variables as shown below.

## Environment Variables
The following environment variables can be used to configure the Convergence server. All environment variables are option, and reasonable defaults are supplied.
 - **CONVERGENCE_ADMIN_USERNAME**: Configures the username of the default server admin user that will be created upon startup.
 - **CONVERGENCE_ADMIN_PASSWORD**: Configures the password of the default server admin user that will be created upon startup.
 - **CONVERGENCE_ADMIN_EMAIL**: Configures the email of the default server admin user that will be created upon startup.
 - **CONVERGENCE_DEFAULT_NAMESPACE**: Configures the default namespace for the server.  Defaults to "convergence".
 
## Common Docker options 
To run in detached mode (in a separate process): `-d`
Give the container a name: `--name convergence`  This allows commands like `docker logs -f convergence` 

## Support
[Convergence Labs](https://convergencelabs.com) provides several different channels for support:

- Please use the [Discourse Forum](https://forum.convergence.io) for general and technical questions, so the whole community can benefit.
- For paid dedicated support or custom development services, [contact us](https://convergence.io/contact-sales/) directly.
- Email <support@convergencelabs.com> for all other inquiries.

## License
The Convergence Omnibus Container is licensed under the [GNU Public License v3](https://www.gnu.org/licenses/gpl-3.0.en.html) (GPLv3) license. Refer to the [LICENSE](https://www.gnu.org/licenses/gpl-3.0.en.html) for the specific terms and conditions of the license.

The Convergence Omnibus Container is also available under a Commercial License. If you are interested in a non-open source license please contact us at [Convergence Labs](https://convergencelabs.com).