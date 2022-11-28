FROM httpd:2.4

# Copy the files
COPY www /usr/local/apache2/htdocs

# Install required OS tools
RUN apt-get update; apt-get install -y perl git build-essential libcgi-session-perl curl imagemagick vim cpanminus

# Install required Perl modules
RUN cpanm --notest DateTime DateTime::Set DateTime::Format::Epoch Astro::PAL Astro::Coords HTML::Template HTML::Template::Expr JSON DateTime::Format::RFC3339 SVG::TT::Graph Tie::Handle::CSV LWP::Simple Text::CSV Switch Parallel::ForkManager

# Remove existing htdocs content
#RUN rm -rf /usr/local/apache2/htdocs/*

# Download Tapir code into Apache htdocs webroot
#RUN git clone https://github.com/aruethe2/Tapir.git /usr/local/apache2/htdocs/

# Download transit targets
RUN curl -o /usr/local/apache2/htdocs/transit_targets.csv https://astro.swarthmore.edu/transits/transit_targets.csv

# Set up cgi for Apache
CMD httpd-foreground -c "LoadModule cgid_module modules/mod_cgid.so"
RUN sed -i 's/Options Indexes FollowSymLinks/Options Indexes FollowSymLinks ExecCGI\n    AddHandler cgi\-script \.cgi/g' /usr/local/apache2/conf/httpd.conf

# Add htdocs directory to Perl path
RUN echo "SetEnv PERL5LIB /usr/local/apache2/htdocs/" >> /usr/local/apache2/conf/httpd.conf

# Restart Apache to implement up new settings
RUN apachectl restart
