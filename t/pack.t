use t::Helper;

{
  use Mojolicious::Lite;
  plugin 'bootstrap3';
  get '/:type' => sub {
    my $c = shift;
    $c->render(text => $c->asset('bootstrap.'.$c->stash('type')));
  };
  app->start;
}

my $t = Test::Mojo->new;

plan skip_all => 'sass is not present' unless $t->app->asset->preprocessors->has_subscribers('scss');

$t->get_ok('/css')->status_is(200)->element_exists('link[href="/packed/bootstrap-4a6855540fc3feeb306465859305cd6e.css"]');
$t->get_ok('/js')->status_is(200)->element_exists('script[src="/packed/bootstrap-6d87c9526ee3bab443a129357c4a072b.js"]');

$t->get_ok('/packed/bootstrap-4a6855540fc3feeb306465859305cd6e.css')
  ->status_is(200)
  ->content_like(qr{Glyphicons Halflings}, 'Glyphicons Halflings')
  ;

$t->get_ok('/packed/bootstrap-6d87c9526ee3bab443a129357c4a072b.js')
  ->status_is(200)
  ->content_like(qr{affix\.js}, 'affix.js')
  ->content_like(qr{alert\.js}, 'alert.js')
  ->content_like(qr{button\.js}, 'button.js')
  ->content_like(qr{carousel\.js}, 'carousel.js')
  ->content_like(qr{collapse\.js}, 'collapse.js')
  ->content_like(qr{dropdown\.js}, 'dropdown.js')
  ->content_like(qr{modal\.js}, 'modal.js')
  ->content_like(qr{popover\.js}, 'popover.js')
  ->content_like(qr{scrollspy\.js}, 'scrollspy.js')
  ->content_like(qr{tab\.js}, 'tab.js')
  ->content_like(qr{tooltip\.js}, 'tooltip.js')
  ->content_like(qr{transition\.js}, 'transition.js')
  ;

SKIP: {
  mkdir 'lib/Mojolicious/Plugin/Bootstrap3/packed';
  skip "Could not create lib/Mojolicious/Plugin/Bootstrap3/packed: $!", 5 unless -d "lib/Mojolicious/Plugin/Bootstrap3/packed";
  shift @{ $t->app->static->paths };
  is int(@{ $t->app->static->paths }), 1, 'only one static path';
  
  opendir(my $DH, 't/public/packed') or die $!;
  for(readdir $DH) {
    next unless /^bootstrap-/;
    unlink "lib/Mojolicious/Plugin/Bootstrap3/packed/$_";
    link "t/public/packed/$_", "lib/Mojolicious/Plugin/Bootstrap3/packed/$_" or die "link t/public/packed/$_: $!";
  }

  $t->get_ok('/packed/bootstrap-4a6855540fc3feeb306465859305cd6e.css')->status_is(200);
  $t->get_ok('/packed/bootstrap-6d87c9526ee3bab443a129357c4a072b.js')->status_is(200);
}

done_testing;
