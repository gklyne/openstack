# keystone-user-info
#
# $1 = username
# $2 = tennant name

USERNAME=$1
TENANTNAME=$2

# Get user id from name

# keystone user-list >user-list.tmp
# +----------------------------------+---------+-------------------------------+--------+
# |                id                | enabled |             email             |  name  |
# +----------------------------------+---------+-------------------------------+--------+
# | 03ec4f390d184f77a5bfff7da80ea238 | True    | nova@hastexo.com              | nova   |
# | 7b7fe99a4854444295d3adcf7cb4a32d | True    | demo@zoo-patmos.zoo.ox.ac.uk  | demo   |
# | afe485b8d03c4451875767aa30afb83b | True    | glance@hastexo.com            | glance |
# | bc64e57a938640a483d313361d8b644a | True    | swift@hastexo.com             | swift  |
# | c65d2df03eac4b9aae19053f816a3d77 | True    | admin@zoo-patmos.zoo.ox.ac.uk | admin  |
# +----------------------------------+---------+-------------------------------+--------+

# keystone tenant-list
# +----------------------------------+--------------------+---------+
# |                id                |        name        | enabled |
# +----------------------------------+--------------------+---------+
# | 2c7a02520a3a41b18d7fcda79a2ded79 | admin              | True    |
# | 70dc8e4cd4d544818e10ef674a68164b | service            | True    |
# | d22b9067be6b4a84a49071bb5e80a2e5 | invisible_to_admin | True    |
# | f6629137f3414779b46be56fef292918 | demo               | True    |
# +----------------------------------+--------------------+---------+

if [[ "$1" == "" || "$2" == "" ]]; then
  echo "Users:"
  keystone user-list | awk "/^\|.*\| True/ { print \$2 \", \" \$8 }"
  echo "Tenants:"
  keystone tenant-list | awk "/^\|.*\| True/ { print \$2 \", \" \$4 }"
  exit
fi

# keystone role-list --user c65d2df03eac4b9aae19053f816a3d77 --tenant 2c7a02520a3a41b18d7fcda79a2ded79
# +----------------------------------+----------------------+
# |                id                |         name         |
# +----------------------------------+----------------------+
# | a10f542625e84752a9036638a19525e3 | KeystoneAdmin        |
# | befb4a28fdd341f78149df1817cd02c5 | admin                |
# | f859c33356dc4f52b8154c8058d36dad | KeystoneServiceAdmin |
# +----------------------------------+----------------------+

function get_user_id () {
    echo `$@ | awk "/^\\|.*\\| True.*\\|.*\\| $USERNAME/ { print \\$2 }"`
}

function get_tenant_id () {
    echo `$@ | awk "/^\\|.*\\| $TENANTNAME.*\\| True.*/ { print \\$2 }"`
}

# echo "userid: $(get_user_id keystone user-list)"
# echo "tenantid $(get_tenant_id keystone tenant-list)"

USERID=$(get_user_id keystone user-list)
TENANTID=$(get_tenant_id keystone tenant-list)

# echo "USERID:$USERID, TENANTID:$TENANTID"

echo "Roles for user $USERNAME, tenant $TENANTNAME"
keystone role-list --user $USERID --tenant $TENANTID
