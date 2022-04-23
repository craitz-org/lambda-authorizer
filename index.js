// layers
const AWS = require('aws-sdk');

// AWS services
const cognitoProviderLib = require('aws-sdk/clients/cognitoidentityserviceprovider');
const cognitoidentityserviceprovider = new cognitoProviderLib();

function buildCustomError(httpStatus, cause) {
  switch (httpStatus) {
      case 400: {
          return JSON.stringify({
              httpStatus,
              type: 'BadRequest',
              cause
          });
      }
      case 401: {
        return JSON.stringify({
            httpStatus,
            type: 'Unauthorized',
            cause
        });
      }
      case 404: {
          return JSON.stringify({
              httpStatus,
              type: 'NotFound',
              cause
          });
      }
      case 409: {
          return JSON.stringify({
              httpStatus,
              type: 'DataIntegrityViolation',
              cause
          });
      }
      case 500: {
          return JSON.stringify({
              httpStatus,
              type: 'InternalServerError',
              cause
          });
      }
      default: {
          return JSON.stringify({
              httpStatus: 500,
              type: 'InternalServerError',
              cause
          });
      }
  }
}

function getAuthParams(credentials) {
    try {
        const [username, password] = Buffer.from(credentials.split(' ')[1], 'base64').toString('ascii').split(':');

        return {
            username,
            password
        }
    } catch (err) {
        throw buildCustomError(400, 'Credencial inválida');
    }
}

async function authorizeUser(clientId, poolId, username, password) {
    try {
        const data = await cognitoidentityserviceprovider.adminInitiateAuth({
            AuthFlow: 'ADMIN_NO_SRP_AUTH',
            ClientId: clientId,
            UserPoolId: poolId,
            AuthParameters: {
                USERNAME: username,
                PASSWORD: password            }
        }).promise();

        if (!data) {
            throw buildCustomError(500, `Erro inesperado autenticando o usuário ${username} no Cognito`);
        }

        return JSON.stringify({
            access_token: data.AuthenticationResult.IdToken,
            token_type: 'Bearer',
            expires_in: 3600,
            scope: 'Read'
        });
    } catch (err) {
        if (err.code === 'NotAuthorizedException') {
            throw buildCustomError(401, `${err.code}: ${err.message}`);
        }

        throw err;
    }
}

exports.handler = async (event, context) => {
    try {
        return await authorizeUser(event.clientId, event.poolId, event.username, event.password);
    } catch (err) {
        return err;
    }
};
