resource repo {
        protocol C;
        startup {
                wfc-timeout  15;
                degr-wfc-timeout 40;
        }
        net {
                cram-hmac-alg sha1;
                shared-secret "b5eb86aa76a6136";
        }
        on SERVERNAME1 {
                device /dev/drbd0;
                disk /dev/vdb;
                address IP_FOR_SERVER1:7788;
                meta-disk internal;
        }
        on SERVERNAME2 {
                device /dev/drbd0;
                disk /dev/vdb;
                address IP_FOR_SERVER2:7788;
                meta-disk internal;
        }
}
