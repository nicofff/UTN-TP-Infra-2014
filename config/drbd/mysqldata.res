resource mysqldata {

        options {
                on-no-data-accessible suspend-io;
        }

        net {
                cram-hmac-alg "sha1";
                shared-secret "thaPa55word!1";

                protocol C;
        }


        on db {
                address 192.168.100.11:7788;
                device /dev/drbd0;
                disk /dev/sdb1;
                meta-disk internal;

        }

        on web {
                address 192.168.100.10:7788;
                device /dev/drbd0;
                disk /dev/sdb1;
                meta-disk internal;
        }
}
