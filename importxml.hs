import Text.XML.HXT.Parser.XmlParsec
import Text.XML.HXT.DOM.TypeDefs
import Text.XML.HXT.DOM.QualifiedName
import Data.Tree.NTree.TypeDefs

parcourirXML :: [String] -> NTrees XNode -> String
parcourirXML _ [NTree (XText nom) []] = nom
parcourirXML chemin ((NTree (XTag qTag _) deeperTrees):otherTrees) = parcourirXML chemin (if localPart qTag `elem` chemin then deeperTrees else otherTrees)
parcourirXML _ [] = ""

main = interact $ parcourirXML ["accord", "nom"] . xread . concat . lines

