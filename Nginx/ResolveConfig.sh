sed "/^\s*\($\|#\)/d" nginx.conf | grep -Pzoe "(upstream|location).*{[^}]*}" | sed "/\(upstream\|server\|location\|proxy_pass\)/!d" | sed "/proxy_next_upstream/d"  > nginx.conf1

awk '{ for(i=1;i<=NF;i++)a[NR,i]=$i }
/\s*upstream/ { upName=$2 }
/\s*server/  { a[NR,1]=upName }
{ if ( NF == 3 && $1 ~ /^\s*location/ ) lcName=$2 }
{ if ( NF == 4 && $1 ~ /^\s*location/ ) lcName=$3 }
/\s*proxy_pass/  { a[NR,1]=lcName }
END { 
for(j=1;j<=NR;j++)
if ( a[j,1] ~ /^upstream|^location/ )
continue
else
{for(i=1;i<=2;i++)  #NF在END中无效
printf a[j,i]" "
print huanghang }   #不加引号表示换行
}' nginx.conf1 > nginx.conf2

awk '{ if ( $2 !~ /\s*[0-9]/ )
{ a[NR]=$1
URI[NR][30]=substr($2,8)
SERVER[NR][30]=substr(URI[NR][30],1,index(URI[NR][30],"/") - 1 )
PROXY_PASS[NR][30]=substr(URI[NR][30],index(URI[NR][30],"/") )
print a[NR],SERVER[NR][30],PROXY_PASS[NR][30]
} else print $0
}' nginx.conf2 > nginx.conf3