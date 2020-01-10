function varargout = GUI(varargin)
% GUI MATLAB code for GUI.fig
%      GUI, by itself, creates a new GUI or raises the existing
%      singleton*.
%
%      H = GUI returns the handle to a new GUI or the handle to
%      the existing singleton*.
%
%      GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI.M with the given input arguments.
%
%      GUI('Property','Value',...) creates a new GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUI

% Last Modified by GUIDE v2.5 06-Jan-2020 15:15:59

% Begin initialization code - DO NOT EDIT
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
% End initialization code - DO NOT EDIT


% --- Executes just before GUI is made visible.
function GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUI (see VARARGIN)
vol_ref = varargin{1};
vol_shift = varargin{2};
n_slices =  size(vol_ref,3);

handles.current_data.vol1 = vol_ref;
handles.current_data.vol2 = vol_shift;
handles.current_data.slice = 1;
handles.selected_dots.vol1 = cell(n_slices,1);
handles.selected_dots.vol2 = cell(n_slices,1);

axes(handles.axes1);
handles.image1 = clickableimage(handles.current_data.vol1(:,:,handles.current_data.slice));
set(handles.axes1, 'Tag', 'vol1')

axes(handles.axes2);
handles.image2 = clickableimage(handles.current_data.vol2(:,:,handles.current_data.slice));
set(handles.axes2, 'Tag', 'vol2')

set(handles.popupmenu1,'String',1:n_slices,'Value',1);


% Choose default command line output for GUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GUI wait for user response (see UIRESUME)

uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{2} = handles.output;
varargout{1} = handles.selected_dots;


% --- Executes on button press in pushbutton1.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiresume(handles.figure1);

% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Determine the selected data set.
str = get(hObject, 'String');
val = get(hObject,'Value');
% Set current data to the selected data set.

handles.current_data.slice = val;
guidata(get(hObject, 'Parent'), handles);



axes(handles.axes1);
handles.image1 = clickableimage(handles.current_data.vol1(:,:,handles.current_data.slice));
set(handles.axes1, 'Tag', 'vol1')
dots = handles.selected_dots.vol1{handles.current_data.slice};
if dots
    hold(handles.axes1,'on'); 
    plot(handles.axes1,dots(:,1), dots(:,2), 'rx');
    hold(handles.axes1,'off');
end

axes(handles.axes2);
handles.image2 = clickableimage(handles.current_data.vol2(:,:,handles.current_data.slice));
set(handles.axes2, 'Tag', 'vol2')
dots = handles.selected_dots.vol2{handles.current_data.slice};
if dots
    hold(handles.axes2,'on'); 
    plot(handles.axes2,dots(:,1), dots(:,2), 'rx');
    hold(handles.axes2,'off');
end

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function imageHandle = clickableimage(image)
    imageHandle = imshow(image);
    set(imageHandle,'ButtonDownFcn',@ImageClickCallback);

function ImageClickCallback ( objectHandle , eventData)
    axesHandle  = get(objectHandle,'Parent');
    guiHandle = get(axesHandle,'Parent');
    handles = guidata(guiHandle);
    current_slice = handles.current_data.slice;
    
    coordinates = get(axesHandle,'CurrentPoint'); 
    coordinates = round(coordinates(1,1:2));
    
    vol_id = get(axesHandle,'Tag');
    if strcmp(vol_id, 'vol1')
        %handles.selected_dots.vol1{current_slice} = [handles.selected_dots.vol1{current_slice}; coordinates];
        %with_new_dots = handles.selected_dots.vol1{current_slice};
        
        selected_dots = handles.selected_dots.vol1{current_slice};
        with_new_dots = [selected_dots; coordinates];
        handles.selected_dots.vol1{current_slice} = with_new_dots;
    else
        if strcmp(vol_id, 'vol2')
            selected_dots = handles.selected_dots.vol2{current_slice};
            with_new_dots = [selected_dots; coordinates];
            handles.selected_dots.vol2{current_slice} = with_new_dots;
        end
    end    
     
    hold(axesHandle,'on'); 
    plot(axesHandle,with_new_dots(:,1), with_new_dots(:,2), 'rx');
    hold(axesHandle,'off');
    guidata(guiHandle, handles)

    
    
