package JavaScript::V8::Handlebars;

use 5.006;
use strict;
use warnings;

our $VERSION = '0.01';

use File::ShareDir qw/module_file/;
use JavaScript::V8;

use File::Slurp qw/slurp/;

sub new {
	my( $class, @opts ) = @_;

	my $self = bless {}, $class;

	$self->_build_context;

	return $self;
}

sub _build_context {
	my( $self ) = @_;

	my $c = $self->{c} = JavaScript::V8::Context->new;

	$c->eval( scalar slurp module_file( __PACKAGE__, "handlebars-v3.0.3.js" ) );
	die $@ if $@;

	#$c->eval( 'Handlebars.registerHelper("test", test )' );


	for my $meth ( qw/compile precompile template safeString escapeString/ ) {
		my $code = $self->{$meth} = $c->eval( "Handlebars.$meth" );
		die $@ if $@;
		no strict 'refs';*$meth = sub { shift; $code->(@_); };
	}
}

sub c {
	return $_[0]->{c};
}

sub registerHelper {
	my( $self, $name, $code ) = @_;
	my $bind_name = "JVHELPER$name";

	if( ref $code eq 'CODE' ) {
		$self->c->bind( $bind_name, $code );
		$self->c->eval( "Handlebars.registerHelper('$name',$bind_name)" );
	}
	elsif(ref $code eq '') { #Better be javascript
		# Should this be a requirement?
		if( $code !~ /function\s*\(/ ) { die "Javascript helper must be a anonymous function!" }

		$code =~ s/function/function $bind_name/;

		$self->c->eval($code);
		$self->c->eval( "Handlebars.registerHelper('$name',$bind_name)" );
	}
	else {
		die "Bad helper [$code]";
	}
}

sub render_string {
	my( $self, $template, $env ) = @_;
	$self->compile( $template )->( $env );
}



1;

=head1 NAME

JavaScript::V8::Handlebars - The great new JavaScript::V8::Handlebars!

=head1 VERSION

Version 0.01

=head1 AUTHOR

Robert Grimes, C<< <rmzgrimes at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-javascript-v8-handlebars at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=JavaScript-V8-Handlebars>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

perldoc JavaScript::V8::Handlebars


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=JavaScript-V8-Handlebars>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/JavaScript-V8-Handlebars>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/JavaScript-V8-Handlebars>

=item * Search CPAN

L<http://search.cpan.org/dist/JavaScript-V8-Handlebars/>

=back



=head1 LICENSE AND COPYRIGHT

Copyright 2015 Robert Grimes.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


=cut
