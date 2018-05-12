function theStruct = parseXML(filename)
% PARSEXML Convert XML file to a MATLAB structure.
try
   tree = xmlread(filename);
catch
   error('Failed to read XML file %s.',filename);
end

% Recurse over child nodes. This could run into problems 
% with very deeply nested trees.
% try
   theStruct = parseChildNodes(tree);
% catch
%    error('Unable to parse XML file %s.',filename);
% end


% ----- Local function PARSECHILDNODES -----
function [children]= parseChildNodes(theNode)
% Recurse over node children.
children = [];
name =[];

if theNode.hasChildNodes
   childNodes = theNode.getChildNodes;
   numChildNodes = childNodes.getLength;
%    allocCell = cell(1, numChildNodes);
% 
%    children = struct(             ...
%       'Data', allocCell, 'Children', allocCell);

    for count = 1:numChildNodes
        theChild = childNodes.item(count-1);
        [tmp_struct,name] = makeStructFromNode(theChild);
        
        if isfield(children,name)
            eval(['children.' name '=[children.' name ' tmp_struct]']);
        else
            eval(['children.' name '=tmp_struct']);
        end
    end
end

% ----- Local function MAKESTRUCTFROMNODE -----
function [nodeStruct,name] = makeStructFromNode(theNode)
% Create structure of node info.
  nodeStruct = [];
% 
   name=char(theNode.getNodeName);
   if strcmp(name,'#text')
       name='temp';
   else
       nodeStruct=parseChildNodes(theNode);
   end
   
if any(strcmp(methods(theNode), 'getData'))
   name='data';
   nodeStruct= char(theNode.getData); 
else
%    nodeStruct.Data = '';
end
