function A=imbytefile(filename,linelen);

% A=imbtytefile(filename,linelen);
%
% Displays an image read from a file of binary data.  The file name
% should be specified as the first argument.  The file is assumed
% to be written in line order.  The linelength is the second argument.
% The data is assumed to be unsigned characters, and the color is
% scaled to use the full [0,255] range.

if(nargin~=2),
  disp('usage: imbytefile(filename,linelen)');
  return;
end;

clf;
fp=fopen(filename,'r');
if(fp==-1),
  disp('unable to read from file');
  return;
end;
A=fread(fp,[linelen,inf],'uchar')';
fclose(fp);

imagesc(A,[0,255]);
colormap('bone');
axis('image');
set(gca,'ticklength',[0 0]);
zoom on;

if(nargout==0),
  clear A;
end;