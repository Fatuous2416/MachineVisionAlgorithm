function varargout = GUI(varargin)
gui_Singleton = 1;

gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
               
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
   gui_mainfcn(gui_State, varargin{:});
end

function GUI_OpeningFcn(hObject, eventdata, handles, varargin)

% ����ͼƬ����
set(handles.imageaxes,'visible','off')

% Choose default command line output for GUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);


function varargout = GUI_OutputFcn(hObject, eventdata, handles) 

varargout{1} = handles.output;

% --- Executes on selection change in popupmenuC.
function popupmenuC_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuC contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuC


% --- Executes during object creation, after setting all properties.
function popupmenuC_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% ѡ��ť
function choosebutton_Callback(hObject, eventdata, handles)
% ���ļ�
[filepath,filename] = uigetfile({'*.jpg';'*.bmp'},'Select the Image');

if isempty(filename)
    msgbox('Empty File !!','Warning','warn');
else
    currentfile = [filename,filepath];
    currentimage = imread(currentfile);
    % axes(handles.imageaxes);
    imshow(currentimage);
    title('ԭʼͼƬ');
    handles.currentimage = currentimage;
    % ���ļ�·�����ļ������浽handles����
    handles.filepath = filepath;
    handles.filename = filename;
    
    guidata(hObject,handles);
end

% ��ͼ��ť
function cutbutton_Callback(hObject, eventdata, handles)
h = imcrop();
axes(handles.imageaxes);
imshow(h);
title('��ȡ��ͼƬ');
handles.cutimage = h;
guidata(hObject,handles);

% ȡ����ť
function cancelbutton_Callback(hObject, eventdata, handles)
global  hh1 hh2 hh3;

h = 0;
if ishandle(hh1)
    delete(hh1);h=1;
end
if ishandle(hh2)
    delete(hh2);h=1;
end
if ishandle(hh3)
    delete(hh3);h=1;
end
if h
    handles.imageaxes = axes('parent',handles.imagepanel);
end

cla(handles.imageaxes,'reset');
set(handles.imageaxes,'visible','off')


% ���㰴ť
function confirmbutton_Callback(hObject, eventdata, handles)

testimage = handles.cutimage;

cutimage = rgb2hsv(testimage);

img = cutimage(:,:,1);
cluster_num = 2;    % ���÷�����
maxiter = 60;       % ����������

% kmeans��Ϊ��ʼ��Ԥ�ָ�
label = kmeans(img(:),cluster_num);
label = reshape(label,size(img));
iter = 0;

while iter < maxiter
    %-------�����������---------------
    %�����Ҳ��õ������ص��3*3����ı�ǩ��ͬ�������Ϊ�������
    %------�ռ���������б�Ȱ˸�����ı�ǩ--------
    label_u = imfilter(label,[0,1,0;0,0,0;0,0,0],'replicate');
    label_d = imfilter(label,[0,0,0;0,0,0;0,1,0],'replicate');
    label_l = imfilter(label,[0,0,0;1,0,0;0,0,0],'replicate');
    label_r = imfilter(label,[0,0,0;0,0,1;0,0,0],'replicate');
    label_ul = imfilter(label,[1,0,0;0,0,0;0,0,0],'replicate');
    label_ur = imfilter(label,[0,0,1;0,0,0;0,0,0],'replicate');
    label_dl = imfilter(label,[0,0,0;0,0,0;1,0,0],'replicate');
    label_dr = imfilter(label,[0,0,0;0,0,0;0,0,1],'replicate');
    p_c = zeros(cluster_num,size(label,1)*size(label,2));
    
    % �������ص�8�����ǩ�����ÿһ�����ͬ����
    for i = 1:cluster_num
        label_i = i * ones(size(label));
        temp = ~(label_i - label_u) + ~(label_i - label_d) + ...
            ~(label_i - label_l) + ~(label_i - label_r) + ...
            ~(label_i - label_ul) + ~(label_i - label_ur) + ...
            ~(label_i - label_dl) +~(label_i - label_dr);
        p_c(i,:) = temp(:)/8;% �������
    end
    p_c(p_c == 0) = 0.001;% ��ֹ����0
    %---------------������Ȼ����----------------
    mu = zeros(1,cluster_num);
    sigma = zeros(1,cluster_num);
    %���ÿһ��ĵĸ�˹����--��ֵ����
    for i = 1:cluster_num
        index = label == i;%�ҵ�ÿһ��ĵ�
        data_c = double(img(index));
        mu(i) = mean(data_c);%��ֵ
        sigma(i) = var(data_c);%����
    end
    p_sc = zeros(cluster_num,size(label,1)*size(label,2));
    %------����ÿ�����ص�����ÿһ�����Ȼ����--------
    %------Ϊ�˼������㣬��ѭ����Ϊ����һ�����--------
    for j = 1:cluster_num
        MU = repmat(mu(j),size(img,1)*size(img,2),1);
        p_sc(j,:) = 1/sqrt(2*pi*sigma(j))*...
            exp(-(double(img(:))-MU).^2/2/sigma(j));
    end 
    %�ҵ�����һ�����������Ϊ��ǩ��ȡ������ֵֹ̫С
    [~,label] = max(log(p_c) + log(p_sc));
    %�Ĵ�С������ʾ
    label = reshape(label,size(img));
    iter = iter + 1;
end

m = numel(label);
x = length(find(label==1));
y = min(x,m-x);

% ��ȡ
val = get(handles.popupmenuC,'value');
switch val
    case 1
        % Roberts
        BW = edge(label,'Roberts',0.04);
        g = length(find(BW==1))/2;
        h = y/g;
    case 2
        % Sobel
        BW = edge(label,'Sobel',0.04);
        g = length(find(BW==1))/2;
        h = y/g;
    case 3
        % Prewitt
        BW = edge(label,'Prewitt',0.04);
        g = length(find(BW==1))/2;
        h = y/g;
    case 4
        % LOG
        BW = edge(label,'LOG',0.004);
        g = length(find(BW==1))/2;
        h = y/g;
    case 5
        % Canny
        BW = edge(label,'Canny',0.04);
        g = length(find(BW==1))/2;
        h = y/g;
    otherwise
        % Sobel
        BW = edge(label,'Sobel',0.04);
        g = length(find(BW==1))/2;
        h = y/g;
end

% ��ʾ
global hh1 hh2 hh3;

str = ['����Ѫ�ܿ�ȣ�',num2str(h),'����'];

hh1 = subplot(2,2,[1,2]);
imshow(testimage)
title({str;'��ȡ��ͼƬ'})

hh2 = subplot(2,2,3);
imshow(label,[])
title('�ָ��ͼ��')

hh3 = subplot(2,2,4);
imshow(BW)
title(' ��Ե��� ')
