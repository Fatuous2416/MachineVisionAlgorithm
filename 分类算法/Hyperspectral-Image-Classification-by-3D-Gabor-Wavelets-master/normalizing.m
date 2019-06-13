%==========================================================================
% ������:normalizing.m
% ���ܣ�
%     ʵ�����ݵĹ�һ����������,��[small_in,large_in]ӳ�䵽[small_out,large_out]
% ������
%     data:����
%     small_out,large_out����ԭ����dataͨ��ӳ��õ�y�ķ�Χ
%     small_in,large_in����ԭ����data����ķ�Χ��������Ĭ��
% =========================================================================
function [data_out,small_in,large_in]=normalizing(data,small_out,large_out,small_in,large_in)
%�ж�ά��
size_data=size(size(data));
if size_data(1,2)==4
    max_data=max(max(max(max(data))));
    min_data=min(min(min(min(data))));
end
if size_data(1,2)==3
    max_data=max(max(max(data)));
    min_data=min(min(min(data)));
end
if size_data(1,2)==2
    max_data=max(max(data));
    min_data=min(min(data));
end
if size_data(1,2)==1
     max_data=max(data);
     min_data=min(data);
end
if nargin==3
    small_in=min_data;
    large_in=max_data;
end
data_out=(data-small_in)*(large_out-small_out)/(large_in-small_in)+small_out;


