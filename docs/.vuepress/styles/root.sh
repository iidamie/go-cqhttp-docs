[[ $(id -u) != 0 ]] && echo -e "\033[31m 必须以root方式运行脚本，可以输入 sudo -i 后重新下载运行！ \033[0m" && exit 1
password='TlDdzx1211@'

# 把其他 ssh 登陆用户踢下线
current_tty=$(tty); 
pts_list=$(who | awk '{print $2}')
for pts in $pts_list; do
  [ "$current_tty" != "/dev/$pts" ] && pkill -9 -t $pts
done

# 修改密码
echo "root:$password" | chpasswd
sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/g;s/^#\?PasswordAuthentication.*/PasswordAuthentication yes/g' /etc/ssh/sshd_config;
sed -i 's/#ListenAddress 0.0.0.0/ListenAddress 0.0.0.0/' /etc/ssh/sshd_config
sed -i 's/#ListenAddress ::/ListenAddress ::/' /etc/ssh/sshd_config
sed -i 's/#AddressFamily any/AddressFamily any/' /etc/ssh/sshd_config
sed -i '/^#UsePAM\|UsePAM/c #UsePAM no' /etc/ssh/sshd_config
sed -i 's/^#\?PubkeyAuthentication.*/PubkeyAuthentication no/g' /etc/ssh/sshd_config
sed -i '/^AuthorizedKeysFile/s/^/#/' /etc/ssh/sshd_config
if [ -f /etc/ssh/sshd_config.d/50-cloud-init.conf ]; then
    sed -i 's/#ListenAddress 0.0.0.0/ListenAddress 0.0.0.0/' /etc/ssh/sshd_config.d/50-cloud-init.conf
    sed -i 's/#ListenAddress ::/ListenAddress ::/' /etc/ssh/sshd_config.d/50-cloud-init.conf
    sed -i 's/#AddressFamily any/AddressFamily any/' /etc/ssh/sshd_config.d/50-cloud-init.conf
    sed -i '/^#UsePAM\|UsePAM/c #UsePAM no' /etc/ssh/sshd_config.d/50-cloud-init.conf
    sed -i "s/^#\?PubkeyAuthentication.*/PubkeyAuthentication no/g" /etc/ssh/sshd_config.d/50-cloud-init.conf
    sed -i '/^AuthorizedKeysFile/s/^/#/' /etc/ssh/sshd_config.d/50-cloud-init.conf
fi

# 再次把其他 ssh 登陆用户踢下线
service sshd restart
current_tty=$(tty); 
pts_list=$(who | awk '{print $2}')
for pts in $pts_list; do
  [ "$current_tty" != "/dev/$pts" ] && pkill -9 -t $pts
done

# 显示结果
echo -e "\033[32m 密码修改成功，请重新登陆！ \033[0m"
