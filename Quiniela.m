function varargout = Quiniela(varargin)
% QUINIELA MATLAB code for Quiniela.fig
%      QUINIELA, by itself, creates a new QUINIELA or raises the existing
%      singleton*.
%
%      H = QUINIELA returns the handle to a new QUINIELA or the handle to
%      the existing singleton*.
%
%      QUINIELA('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in QUINIELA.M with the given input arguments.
%
%      QUINIELA('Property','Value',...) creates a new QUINIELA or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Quiniela_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Quiniela_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Quiniela

% Last Modified by GUIDE v2.5 02-Sep-2017 18:13:09

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Quiniela_OpeningFcn, ...
                   'gui_OutputFcn',  @Quiniela_OutputFcn, ...
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


% --- Executes just before Quiniela is made visible.
function Quiniela_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Quiniela (see VARARGIN)

% Choose default command line output for Quiniela
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Quiniela wait for user response (see UIRESUME)
% uiwait(handles.figure1);
lst

% --- Outputs from this function are returned to the command line.
function varargout = Quiniela_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in lstPrimera.
function lstPrimera_Callback(hObject, eventdata, handles)
% hObject    handle to lstPrimera (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of lstPrimera


% --- Executes during object creation, after setting all properties.
function lstPrimera_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lstPrimera (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in togglebutton1.
function togglebutton1_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of togglebutton1


% --- Executes on button press in cmdAddTeam.
function cmdAddTeam_Callback(hObject, eventdata, handles)
% hObject    handle to cmdAddTeam (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
