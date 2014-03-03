local PANEL = {}

function PANEL:Init()

    self.LastW = 0
    self.LastH = 0
    
    self:SetDrawBackground(false)

end

function PANEL:Row(space)
    local p = self:Add("DTableRow")
    p:SetTall(space or 0)
end

function PANEL:Layout()
    self.LastW = 0;
    self.LastH = 0;
    self:InvalidateLayout()
end

function PANEL:LayoutCells()

    local maxwidth = self:GetWide()
    
    local rows = {}
    local rowidx = 1
    
    local chld = self:GetChildren()
    local lastrow
    
    for k, v in pairs( chld ) do
    
        if ( !v:IsValid() or !v:IsVisible() ) then continue end
        if v.IsRow then
            if lastrow then lastrow.fheight = (lastrow.height or 0) + v:GetTall() end
            rowidx = rowidx + 1
            continue
        end
        
        local cw, ch = v:GetWide(), v:GetTall()
        
        rows[rowidx] = rows[rowidx] or {}
        local row = rows[rowidx]
        
        row.elements = row.elements or {}
        table.insert(row.elements, v)
        
        row.height = math.max(row.height or 0, ch)
        
        local config = v.TableConfig
        row.xcells = (row.xcells or 0) + (config and config.Colspan or 1)
        
        lastrow = row
    
    end

    local cury = 0
    for _,row in ipairs(rows) do
        local widthperelement = maxwidth / (row.xcells or 1)
        local nthxcell = 0
        for i,el in pairs(row.elements) do
            el:SetPos(nthxcell * widthperelement, cury)
            
            local config = el.TableConfig
            if not config then config = {} el.TableConfig = config end
            
            local colspan = 1
            
            if config.Colspan then colspan = config.Colspan end
            if config.FillX or config.Fill then el:SetWide(widthperelement*colspan) end
            if config.FillY or config.Fill then el:SetTall(row.height) end
            --if config.Padding then el:DockMargin(config.Padding, config.Padding, config.Padding, config.Padding) end
            
            nthxcell = nthxcell + colspan
        end
        cury = cury + (row.fheight or row.height) -- fheight is not nil if row had a tall value
    end

end

function PANEL:PerformLayout()

    local ShouldLayout = false;
    
    if ( self.LastW != self:GetWide()) then ShouldLayout = true end
    if ( self.LastH != self:GetTall()) then ShouldLayout = true end
    
    self.LastW = self:GetWide()
    self.LastH = self:GetTall()
    
    if ( ShouldLayout ) then
        self:LayoutCells()
    end
    
    local w, h = self:ChildrenSize();
    h = math.max( h, self:GetTall() )
    
    self:SetHeight( h )

end

function PANEL:OnModified()
    -- Override me
end

function PANEL:OnChildRemoved()
    self:Layout()
end

--[[
function PANEL:OnChildAdded( child )

local dn = self:GetDnD()
if ( dn ) then
child:Droppable( self:GetDnD() );
end

if ( self:IsSelectionCanvas() ) then
child:SetSelectable( true )
end

self:Layout()

end]]

derma.DefineControl( "DTable", "", PANEL, "DPanel" )


local PANEL = {}
PANEL.IsRow = true
function PANEL:Paint()
    return true
end
derma.DefineControl( "DTableRow", "", PANEL, "DPanel" )