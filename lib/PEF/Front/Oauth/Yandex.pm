package PEF::Front::Oauth::Yandex;

use strict;
use warnings;
use base 'PEF::Front::Oauth';
use HTTP::Request::Common;
use feature 'state';

sub _authorization_server {
	'https://oauth.yandex.ru/authorize';
}

sub _token_server {
	'https://oauth.yandex.ru/token';
}

sub _get_user_info_request {
	my ($self) = @_;
	my $req = GET 'https://login.yandex.ru/info';
	$req->query_form(
		format      => 'json',
		oauth_token => $self->{session}->data->{oauth_access_token}{$self->{service}}
	);
	$req;
}

sub _parse_user_info {
	my ($self) = @_;
	state $sizes = [
		'islands-small'         => 28,
		'islands-34'            => 34,
		'islands-middle'        => 42,
		'islands-50'            => 50,
		'islands-retina-small'  => 56,
		'islands-68'            => 68,
		'islands-75'            => 75,
		'islands-retina-middle' => 84,
		'islands-retina-50'     => 100,
		'islands-200'           => 200
	];
	my $info = $self->{session}->data->{oauth_info_raw}{$self->{service}};
	my @avatar;
	if ($info->{default_avatar_id}) {
		for (my $i = 0 ; $i < @$sizes ; $i += 2) {
			my $sn   = $sizes->[$i];
			my $size = $sizes->[$i + 1];
			push @avatar,
			  { url  => "https://avatars.yandex.net/get-yapic/$info->{default_avatar_id}/$sn",
				size => $size
			  };
		}
	}
	my $name = $info->{display_name} || $info->{real_name} || '';
	return {
		name   => $name,
		email  => $info->{default_email} || '',
		login  => $info->{login} || '',
		avatar => \@avatar,
	};
}

sub new {
	my ($class, $self) = @_;
	bless $self, $class;
}

1;
