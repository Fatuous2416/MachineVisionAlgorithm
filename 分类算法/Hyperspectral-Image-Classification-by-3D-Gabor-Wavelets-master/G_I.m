function [ Gabor_out ] = G_I( dir )
%G_I����indian_pineͼ�����һ�������GaborС������Ӧ
%���뷽������gabor_output ��145x145x200���󣬱�ʾ��Ӧ���ķ��ȣ�

global indian_pines_corrected;

S=(2*pi).^-1.5;  %����S������������¶�Ϊ����
g_gauss=@(x,y,b,xc,yc,bc)exp( (x.^2+y^2+b^2)./(-2) );  %GaborС���ĸ�˹���־����ֻ��任���λ���벨�����й�
%���ڱ�������һ����������Ϊ��λ���м��㣬����һ���������ϵĵ�b��������ͬ��b��bc��ȣ�������ȥ���


%GaborС�������Ҳ��־������任���λ�á��������Լ�ѡȡ�ķ����йأ���ʵ����һ����52��
g_s1=@(x,y,b)exp(2i*pi*(b./2));   
g_s2=@(x,y,b)exp(2i*pi*((x+b)./sqrt(2)));
g_s3=@(x,y,b)exp(2i*pi*(x./4+y./4+b.*sqrt(2)./4));
g_s4=@(x,y,b)exp(2i*pi*((y+b).*sqrt(2)./4));
g_s5=@(x,y,b)exp(2i*pi*(-x./4+y./4+b.*sqrt(2)./4));
g_s6=@(x,y,b)exp(2i*pi*(x./2));
g_s7=@(x,y,b)exp(2i*pi*(sqrt(2).*(x+y)./4));
g_s8=@(x,y,b)exp(2i*pi*(y./2));
g_s9=@(x,y,b)exp(2i*pi*((-x+y).*sqrt(2)./4));
g_s10=@(x,y,b)exp(2i*pi*(sqrt(2).*(x-b)./2));
g_s11=@(x,y,b)exp(2i*pi*(x./4+y./4-b.*sqrt(2)./4));
g_s12=@(x,y,b)exp(2i*pi*((y-b).*sqrt(2)./4));
g_s13=@(x,y,b)exp(2i*pi*(-x./4+y./4-b.*sqrt(2)./4));
g_s14=@(x,y,b)exp(2i*pi*(b./4));
g_s15=@(x,y,b)exp(2i*pi*(sqrt(2).*(x+b)./4));
g_s16=@(x,y,b)exp(2i*pi*(x./8+y./8+b.*sqrt(2)./8));
g_s17=@(x,y,b)exp(2i*pi*((y+b).*sqrt(2)./8));
g_s18=@(x,y,b)exp(2i*pi*(-x./8+y./8+b.*sqrt(2)./8));
g_s19=@(x,y,b)exp(2i*pi*(x./4));
g_s20=@(x,y,b)exp(2i*pi*(sqrt(2).*(x+y)./8));
g_s21=@(x,y,b)exp(2i*pi*(y./4));
g_s22=@(x,y,b)exp(2i*pi*((-x+y).*sqrt(2)./8));
g_s23=@(x,y,b)exp(2i*pi*(sqrt(2).*(x-b)./4));
g_s24=@(x,y,b)exp(2i*pi*(x./8+y./8-b.*sqrt(2)./8));
g_s25=@(x,y,b)exp(2i*pi*((y-b).*sqrt(2)./8));
g_s26=@(x,y,b)exp(2i*pi*(-x./8+y./8-b.*sqrt(2)./16));
g_s27=@(x,y,b)exp(2i*pi*(b./8));
g_s28=@(x,y,b)exp(2i*pi*(sqrt(2).*(x+b)./8));
g_s29=@(x,y,b)exp(2i*pi*(x./16+y./16+b.*sqrt(2)./16));
g_s30=@(x,y,b)exp(2i*pi*((y+b)./sqrt(2)./16));
g_s31=@(x,y,b)exp(2i*pi*(-x./16+y./16+b.*sqrt(2)./16));
g_s32=@(x,y,b)exp(2i*pi*(x./8));
g_s33=@(x,y,b)exp(2i*pi*(sqrt(2).*(x+y)./16));
g_s34=@(x,y,b)exp(2i*pi*(y./8));
g_s35=@(x,y,b)exp(2i*pi*((-x+y).*sqrt(2)./16));
g_s36=@(x,y,b)exp(2i*pi*(sqrt(2).*(x-b)./8));
g_s37=@(x,y,b)exp(2i*pi*(x./16+y./16-b.*sqrt(2)./16));
g_s38=@(x,y,b)exp(2i*pi*((y-b).*sqrt(2)./16));
g_s39=@(x,y,b)exp(2i*pi*(-x./16+y./16-b.*sqrt(2)./16));
g_s40=@(x,y,b)exp(2i*pi*(b./16));
g_s41=@(x,y,b)exp(2i*pi*(sqrt(2).*(x+b)./16));
g_s42=@(x,y,b)exp(2i*pi*(x./32+y./32+b.*sqrt(2)./32));
g_s43=@(x,y,b)exp(2i*pi*((y+b).*sqrt(2)./32));
g_s44=@(x,y,b)exp(2i*pi*(-x./32+y./32+b.*sqrt(2)./32));
g_s45=@(x,y,b)exp(2i*pi*(x./16));
g_s46=@(x,y,b)exp(2i*pi*(sqrt(2).*(x+y)./32));
g_s47=@(x,y,b)exp(2i*pi*(y./16));
g_s48=@(x,y,b)exp(2i*pi*((-x+y).*sqrt(2)./32));
g_s49=@(x,y,b)exp(2i*pi*(sqrt(2).*(x-b)./16));
g_s50=@(x,y,b)exp(2i*pi*(x./32+y./32-b.*sqrt(2)./32));
g_s51=@(x,y,b)exp(2i*pi*((y-b).*sqrt(2)./32));
g_s52=@(x,y,b)exp(2i*pi*(-x./32+y./32-b*sqrt(2)./32));

%����������������ڲ���
g_s={g_s1,g_s2,g_s3,g_s4,g_s5,g_s6,g_s7,g_s8,g_s9,g_s10,g_s11,g_s12,g_s13,g_s14,g_s15,g_s16,g_s17,g_s18,g_s19,g_s20, ...,
    g_s21,g_s22,g_s23,g_s24,g_s25,g_s26,g_s27,g_s28,g_s29,g_s30,g_s31,g_s32,g_s33,g_s34,g_s35,g_s36,g_s37,g_s38,g_s39,g_s40, ...,
    g_s41,g_s42,g_s43,g_s44,g_s45,g_s46,g_s47,g_s48,g_s49,g_s50,g_s51,g_s52};

g_dir=g_s{dir};
%����12x12x12�Ĵ�
for x=-6:5
    for y=-6:5
        for b=-6:5
            G(x+7,y+7,b+7)=g_dir(x,y,b)*g_gauss(x,y,b);   
        end
    end
end
G=G.*S;

Gabor_out=abs(convn(indian_pines_corrected,double(G),'same')); %ȡģΪ��Ӧ

end

