# --
# Copyright (C) 2001-2017 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

use strict;
use warnings;
use utf8;

use vars (qw($Self));

$Kernel::OM->ObjectParamAdd(
    'Kernel::System::UnitTest::Helper' => {
        RestoreDatabase      => 1,
        RestoreConfiguration => 1,
    },
);
my $Helper           = $Kernel::OM->Get('Kernel::System::UnitTest::Helper');
my $ConfigObject     = $Kernel::OM->Get('Kernel::Config');
my $PostMasterFilter = $Kernel::OM->Get('Kernel::System::PostMaster::Filter');

$ConfigObject->Set(
    Key   => 'Ticket::Article::Backend::MIMEBase::ArticleStorage',
    Value => "Kernel::System::Ticket::Article::Backend::MIMEBase::ArticleStorageDB",
);

my $RandomID = $Helper->GetRandomID();

my @Tests = (
    {
        Name   => 'TransitionActionAdd Filter simple',
        Config => {
            Name           => "Filter-$RandomID",
            StopAfterMatch => 0,
            Match          => {
                Subject => 'test',
                To      => 'EMAILADDRESS:darthvader@otrs.org',
            },
            Set => {
                'X-OTRS-Queue'        => 'Misc',
                'X-OTRS-TicketKey1'   => 'Key1',
                'X-OTRS-TicketValue1' => 'Text1',
            },
        },
        ExpectedConfigResult => {
            Name           => "Filter-$RandomID",
            StopAfterMatch => 0,
            Match          => {
                Subject => 'test',
                To      => 'EMAILADDRESS:darthvader@otrs.org',
            },
            Set => {
                'X-OTRS-Queue'        => 'Misc',
                'X-OTRS-TicketKey1'   => 'Key1',
                'X-OTRS-TicketValue1' => 'Text1',
            },
            Not => {
                Subject => undef,
                To      => undef,
            },
        },
    },

    {
        Name   => 'TransitionActionAdd Filter ArticleType Is Not Visible',
        Config => {
            Name           => "FilterATN-$RandomID",
            StopAfterMatch => 0,
            Match          => {
                Subject => 'test',
                To      => 'EMAILADDRESS:darthvader@otrs.org',
            },
            Set => {
                'X-OTRS-ArticleType'  => 'email',
                'X-OTRS-TicketKey1'   => 'Key1',
                'X-OTRS-TicketValue1' => 'Text1',
            },
        },
        ExpectedConfigResult => {
            Name           => "FilterATN-$RandomID",
            StopAfterMatch => 0,
            Match          => {
                Subject => 'test',
                To      => 'EMAILADDRESS:darthvader@otrs.org',
            },
            Set => {
                'X-OTRS-IsVisibleForCustomer' => 0,
                'X-OTRS-TicketKey1'           => 'Key1',
                'X-OTRS-TicketValue1'         => 'Text1',
            },
            Not => {
                Subject => undef,
                To      => undef,
            },
        },
    },
    {
        Name   => 'TransitionActionAdd Filter ArticleType IsVisible',
        Config => {
            Name           => "FilterAT-$RandomID",
            StopAfterMatch => 0,
            Match          => {
                Subject => 'test',
                To      => 'EMAILADDRESS:darthvader@otrs.org',
            },
            Set => {
                'X-OTRS-ArticleType'  => 'phone',
                'X-OTRS-TicketKey1'   => 'Key1',
                'X-OTRS-TicketValue1' => 'Text1',
            },
        },
        ExpectedConfigResult => {
            Name           => "FilterAT-$RandomID",
            StopAfterMatch => 0,
            Match          => {
                Subject => 'test',
                To      => 'EMAILADDRESS:darthvader@otrs.org',
            },
            Set => {
                'X-OTRS-IsVisibleForCustomer' => 1,
                'X-OTRS-TicketKey1'           => 'Key1',
                'X-OTRS-TicketValue1'         => 'Text1',
            },
            Not => {
                Subject => undef,
                To      => undef,
            },
        },
    },

    {
        Name   => 'TransitionActionAdd Filter FollowUp ArticleType Is Not Visible',
        Config => {
            Name           => "FilterFATN-$RandomID",
            StopAfterMatch => 0,
            Match          => {
                Subject => 'test',
                To      => 'EMAILADDRESS:darthvader@otrs.org',
            },
            Set => {
                'X-OTRS-FollowUp-ArticleType' => 'email',
                'X-OTRS-TicketKey1'           => 'Key1',
                'X-OTRS-TicketValue1'         => 'Text1',
            },
        },
        ExpectedConfigResult => {
            Name           => "FilterFATN-$RandomID",
            StopAfterMatch => 0,
            Match          => {
                Subject => 'test',
                To      => 'EMAILADDRESS:darthvader@otrs.org',
            },
            Set => {
                'X-OTRS-FollowUp-IsVisibleForCustomer' => 0,
                'X-OTRS-TicketKey1'                    => 'Key1',
                'X-OTRS-TicketValue1'                  => 'Text1',
            },
            Not => {
                Subject => undef,
                To      => undef,
            },
        },
    },
    {
        Name   => 'TransitionActionAdd Filter FollowUp ArticleType IsVisible',
        Config => {
            Name           => "FilterFAT-$RandomID",
            StopAfterMatch => 0,
            Match          => {
                Subject => 'test',
                To      => 'EMAILADDRESS:darthvader@otrs.org',
            },
            Set => {
                'X-OTRS-FollowUp-ArticleType' => 'phone',
                'X-OTRS-TicketKey1'           => 'Key1',
                'X-OTRS-TicketValue1'         => 'Text1',
            },
        },
        ExpectedConfigResult => {
            Name           => "FilterFAT-$RandomID",
            StopAfterMatch => 0,
            Match          => {
                Subject => 'test',
                To      => 'EMAILADDRESS:darthvader@otrs.org',
            },
            Set => {
                'X-OTRS-FollowUp-IsVisibleForCustomer' => 1,
                'X-OTRS-TicketKey1'                    => 'Key1',
                'X-OTRS-TicketValue1'                  => 'Text1',
            },
            Not => {
                Subject => undef,
                To      => undef,
            },
        },
    },

    {
        Name   => 'TransitionActionAdd Filter Both ArticleType Is Not Visible',
        Config => {
            Name           => "FilterBATN-$RandomID",
            StopAfterMatch => 0,
            Match          => {
                Subject => 'test',
                To      => 'EMAILADDRESS:darthvader@otrs.org',
            },
            Set => {
                'X-OTRS-ArticleType'          => 'email',
                'X-OTRS-FollowUp-ArticleType' => 'email',
                'X-OTRS-TicketKey1'           => 'Key1',
                'X-OTRS-TicketValue1'         => 'Text1',
            },
        },
        ExpectedConfigResult => {
            Name           => "FilterBATN-$RandomID",
            StopAfterMatch => 0,
            Match          => {
                Subject => 'test',
                To      => 'EMAILADDRESS:darthvader@otrs.org',
            },
            Set => {
                'X-OTRS-IsVisibleForCustomer'          => 0,
                'X-OTRS-FollowUp-IsVisibleForCustomer' => 0,
                'X-OTRS-TicketKey1'                    => 'Key1',
                'X-OTRS-TicketValue1'                  => 'Text1',
            },
            Not => {
                Subject => undef,
                To      => undef,
            },
        },
    },
    {
        Name   => 'TransitionActionAdd Filter Both ArticleType IsVisible',
        Config => {
            Name           => "FilterBAT-$RandomID",
            StopAfterMatch => 0,
            Match          => {
                Subject => 'test',
                To      => 'EMAILADDRESS:darthvader@otrs.org',
            },
            Set => {
                'X-OTRS-ArticleType'          => 'phone',
                'X-OTRS-FollowUp-ArticleType' => 'phone',
                'X-OTRS-TicketKey1'           => 'Key1',
                'X-OTRS-TicketValue1'         => 'Text1',
            },
        },
        ExpectedConfigResult => {
            Name           => "FilterBAT-$RandomID",
            StopAfterMatch => 0,
            Match          => {
                Subject => 'test',
                To      => 'EMAILADDRESS:darthvader@otrs.org',
            },
            Set => {
                'X-OTRS-IsVisibleForCustomer'          => 1,
                'X-OTRS-FollowUp-IsVisibleForCustomer' => 1,
                'X-OTRS-TicketKey1'                    => 'Key1',
                'X-OTRS-TicketValue1'                  => 'Text1',
            },
            Not => {
                Subject => undef,
                To      => undef,
            },
        },
    },
    {
        Name   => 'TransitionActionAdd Filter Both ArticleType IsVisible',
        Config => {
            Name           => "FilterBBAT-$RandomID",
            StopAfterMatch => 0,
            Match          => {
                Subject => 'test',
                To      => 'EMAILADDRESS:darthvader@otrs.org',
            },
            Set => {
                'X-OTRS-ArticleType'          => 'email',
                'X-OTRS-FollowUp-ArticleType' => 'phone',
                'X-OTRS-TicketKey1'           => 'Key1',
                'X-OTRS-TicketValue1'         => 'Text1',
            },
        },
        ExpectedConfigResult => {
            Name           => "FilterBBAT-$RandomID",
            StopAfterMatch => 0,
            Match          => {
                Subject => 'test',
                To      => 'EMAILADDRESS:darthvader@otrs.org',
            },
            Set => {
                'X-OTRS-IsVisibleForCustomer'          => 0,
                'X-OTRS-FollowUp-IsVisibleForCustomer' => 1,
                'X-OTRS-TicketKey1'                    => 'Key1',
                'X-OTRS-TicketValue1'                  => 'Text1',
            },
            Not => {
                Subject => undef,
                To      => undef,
            },
        },
    },
);

for my $Test (@Tests) {

    my $FilterAddResult = $PostMasterFilter->FilterAdd( %{ $Test->{Config} } );

    $Self->True(
        $FilterAddResult,
        "$Test->{Name} | Successful FilterAdd ",
    );

    my %Filter = $PostMasterFilter->FilterGet( %{ $Test->{Config} } );

    $Self->Is(
        ref \%Filter,
        'HASH',
        "Filter structure is HASH",
    );

    my $DBUpdateObject = $Kernel::OM->Create('scripts::DBUpdateTo6::MigratePostMasterData');
    $Self->True(
        $DBUpdateObject,
        'Database update object successfully created!',
    );

    my $RunSuccess = $DBUpdateObject->Run();

    $Self->Is(
        1,
        $RunSuccess,
        'DBUpdateObject ran without problems.',
    );

    %Filter = $PostMasterFilter->FilterGet( %{ $Test->{Config} } );

    $Self->Is(
        ref \%Filter,
        'HASH',
        "Filter structure is HASH",
    );

    $Self->IsDeeply(
        \%Filter,
        $Test->{ExpectedConfigResult},
        "$Test->{Name} | Expected config result.",
    );

}

# Cleanup is done by TmpDatabaseCleanup().

1;
