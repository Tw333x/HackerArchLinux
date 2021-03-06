#!/usr/bin/perl
use strict;
use warnings 'FATAL' => 'all';
use Cwd;
use Term::ANSIColor;
use IO::File;

require ConsolePrintTemplates;
use lib sprintf( "%s/lib" , getcwd());
use HackerArch::Install qw( :ALL );
use HackerArch::Setup qw( :ALL );

sub Start {
	HackerArch::Install::UpdateDnsServers();
	HackerArch::Install::InitUsermode();
	HackerArch::Install::InstallFirefoxESR();
	HackerArch::Install::InstallVirtBox();
	HackerArch::Install::AddGdbAsm();
	HackerArch::Install::Nvidia();
}

BEGIN {
	Start();

	ConsolePrintTemplates::CategoryHeading( "This is the section that add Arch User Repository to your system." );
	print "Press 'ENTER' to continue.";
	<>;
}

END {
	ConsolePrintTemplates::CategoryHeading( "Adjusting your newly-installed system with some more personalization" );

	ConsolePrintTemplates::OperTitle( "Enabling services - reboot into your new system will UI" );
	`systemctl enable iptables`;
	`systemctl enable bluetooth`;
	`systemctl enable NetworkManager`;
	`systemctl enable acpid`;
	`systemctl enable vboxweb`;

	ConsolePrintTemplates::OperHeading( "Adjusting Xorg server video output layout" );
	#	ls /sys/class/drm | grep card | cut -d "-" -f2  --> CARD NAME
	#                                                   --> card resolution
	system( "cp " . getcwd() . "/install/video/intel-nvidia.conf /etc/X11/xorg.conf.d/" );
	ConsolePrintTemplates::CheckReturn( 0 , "" );

	ConsolePrintTemplates::OperHeading( "Adjusting lightdm for displaying on your screen" );
	system( "cp " . getcwd() . "/install/lightdm.conf /etc/lightdm/lightdm.conf" );
	ConsolePrintTemplates::CheckReturn( 0 , "" );

	ConsolePrintTemplates::OperHeading( "Adjusting for i3 registration to look like GNOME" );
	system( "cp " . getcwd() . "/install/profile /home/" . ConsolePrintTemplates::GetUsername() . "/.profile" );
	ConsolePrintTemplates::CheckReturn( 0 , "" );

	ConsolePrintTemplates::OperHeading( "Adding Jetbrains activation server" );
	system( "cp -R " . getcwd() . "/install/jetbrainsrv /opt" );
	ConsolePrintTemplates::CheckReturn( 0 , "" );

	ConsolePrintTemplates::OperHeading( "Adding symlink for execution" );
	system( "ln -s /opt/jetbrainsrv/jetbrains_licsrv.linux.amd64 /usr/local/bin/jetbrainsrv" );
	ConsolePrintTemplates::CheckReturn( 0 , "" );

	ConsolePrintTemplates::OperTitle( "Copy exec to usr-local-bin" );
	system( "cp " . getcwd() . "/install/usr-local-bin/* /usr/local/bin" );
	ConsolePrintTemplates::CheckReturn( 0 , "" );
	system( "chown root.root /usr/local/bin/* " );
	system( "chmod 555 /usr/local/bin/* " );

	ConsolePrintTemplates::OperTitle( "Adding necessary Perl libraries \n\n This might take a while. Please be patient!" );
	system( 'perl -MCPAN -e "install Bundle::CPAN" ' );
	ConsolePrintTemplates::CheckReturn( 0 , "" );
	system( 'perl -MCPAN -e "install Perl::Critic" ' );
	ConsolePrintTemplates::CheckReturn( 0 , "" );
	system( ' perl -MCPAN -e "install Devel::Camelcadedb" ' );
	ConsolePrintTemplates::CheckReturn( 0 , "" );

	print "Press 'ENTER' to continue";
	<>;

	HackerArch::Setup::RemoveInstallAutostart();
	HackerArch::Setup::AddExtrasInstallAutostart();

	`source ~/.bashrc`;
}
