const _ = require('lodash');
const configUser = require('./config_user.json');
const configDefault = require('./config_default.json');

const jenkinsUrl = {
	domain: 'ci.sparkbeyond.com',
	protocol: 'https'
};

const user = {
	baseUrl: getJenkinsUrl(configUser.credentials),
	env: configUser.env
};

const config = _.defaults(user, configDefault);

function getJenkinsUrl(credentials) {
	let credentialsString = credentials
		? `${credentials}@`
		: '';
	return `${jenkinsUrl.protocol}://${credentialsString}${jenkinsUrl.domain}`
}

module.exports = config;
