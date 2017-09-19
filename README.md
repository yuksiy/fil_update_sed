# fil_update_sed

## 概要

SEDスクリプトファイルによるファイルの更新

## 使用方法

### fil_update_sed.sh

例えば、自ネットワーク内に稼働中のサーバがあり、
そのサーバの設定ファイルをVCS で管理する場合、
秘密にすべきユーザ名やパスワードがプレーンテキストで書かれた設定ファイルを
VCS のリポジトリに追加したいが、秘密情報はリポジトリに含めたくない場合に
本ツールを使用する、といった利用方法を想定しています。

例えば、OpenLDAP サーバの最終的な設定ファイル「/etc/ldap/slapd.conf」には
秘密情報が含まれることがあり、その部分が以下のようになる場合、

    (snip)
    acl-bind  bindmethod=simple
              binddn="cn=repl,dc=example,dc=com"
              credentials=PASSWORD
    (snip)

上記のslapd.conf の秘密情報の部分を
任意キーワードで置換したテンプレートファイルを新規に作成します。  
(以下、slapd.conf.tmpl と記載)

    (snip)
    acl-bind  bindmethod=simple
              binddn="@user_repl@"
              credentials=@pass_repl@
    (snip)

さらに上記のslapd.conf.tmpl の任意キーワードの部分を
元の秘密情報に戻すためのSEDスクリプトファイルを新規に作成します。  
(書式はSEDスクリプトの書式に従ってください。)  
(以下、slapd.secrets.sed と記載)

    s/@user_repl@/cn=repl,dc=example,dc=com/g
    s/@pass_repl@/PASSWORD/g

slapd.conf.tmpl には秘密情報が含まれていないため、
VCS のリポジトリに追加することができます。  

slapd.secrets.sed には秘密情報が含まれているため、
VCS のリポジトリとは別の場所で管理し、適切なパーミッションを設定して保護するべきです。

実際にOpenLDAP サーバに最終的な設定ファイル「/etc/ldap/slapd.conf」を
インストールするための参考手順は以下の通りです。

1. 上記で作成した「slapd.conf.tmpl」を対象サーバの「/etc/ldap」ディレクトリにインストールしてください。

2. 上記で作成した「slapd.secrets.sed」を対象サーバの「/etc/ldap」ディレクトリにインストールしてください。

3. 以下のコマンドを実行してください。

    ```
    # fil_update_sed.sh -m モード -o オーナー:グループ /etc/ldap/slapd.secrets.sed /etc/ldap/slapd.conf.tmpl /etc/ldap/slapd.conf
    ```

### その他

* 上記で紹介したツールの詳細については、「ツール名 --help」を参照してください。

## 動作環境

OS:

* Linux
* Cygwin

依存パッケージ または 依存コマンド:

* make (インストール目的のみ)
* [common_sh](https://github.com/yuksiy/common_sh)
* [fil_mk](https://github.com/yuksiy/fil_mk)

## インストール

ソースからインストールする場合:

    (Linux, Cygwin の場合)
    # make install

fil_pkg.plを使用してインストールする場合:

[fil_pkg.pl](https://github.com/yuksiy/fil_tools_pl/blob/master/README.md#fil_pkgpl) を参照してください。

## インストール後の設定

環境変数「PATH」にインストール先ディレクトリを追加してください。

## 最新版の入手先

<https://github.com/yuksiy/fil_update_sed>

## License

MIT License. See [LICENSE](https://github.com/yuksiy/fil_update_sed/blob/master/LICENSE) file.

## Copyright

Copyright (c) 2009-2017 Yukio Shiiya
