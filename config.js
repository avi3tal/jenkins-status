const _ = require('lodash');
const configUser = require('./config_user');

const jenkinsUrl = {
	domain: 'ci.sparkbeyond.com',
	protocol: 'https'
};

const defaults = {
	env: 'DEV',
	rootProjectName: 'Build',
	buildPrefix: undefined
};

const user = {
	baseUrl: getJenkinsUrl(configUser.credentials),
	env: configUser.env
};

const config = _.defaults(user, defaults);

function getJenkinsUrl(credentials) {
	let credentialsString = credentials
		? `${credentials}@`
		: '';
	return `${jenkinsUrl.protocol}://${credentialsString}${jenkinsUrl.domain}`
}

module.exports = config;
