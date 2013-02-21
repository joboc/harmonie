import Data.List
import Control.Applicative

import Text.XML.HXT.Parser.XmlParsec
import Text.XML.HXT.DOM.TypeDefs
import Text.XML.HXT.DOM.QualifiedName
import Data.Tree.NTree.TypeDefs

import System.IO

-- Musical data

data Alteration = DoubleBemol | Bemol | Naturel | Diese | DoubleDiese deriving Eq

data Note = Note {getBlanche :: Int, getAlt :: Alteration} deriving Eq

showNoteId 0 = "Do"
showNoteId 2 = "Re"
showNoteId 4 = "Mi"
showNoteId 5 = "Fa"
showNoteId 7 = "Sol"
showNoteId 9 = "La"
showNoteId 11 = "Si"
showAlt DoubleBemol = "bb"
showAlt Bemol       = "b"
showAlt Naturel     = ""
showAlt Diese       = "#"
showAlt DoubleDiese = "x"

instance Show Note where
    show (Note n a) = showNoteId n ++ showAlt a

readNoteId "Do"  = 0
readNoteId "Re"  = 2
readNoteId "Mi"  = 4
readNoteId "Fa"  = 5
readNoteId "Sol" = 7
readNoteId "La"  = 9
readNoteId "Si"  = 11
readNoteId "C"  = 0
readNoteId "D"  = 2
readNoteId "E"  = 4
readNoteId "F"  = 5
readNoteId "G" = 7
readNoteId "A"  = 9
readNoteId "B"  = 11
readAlt "B" = DoubleBemol
readAlt "b" = Bemol
readAlt ""  = Naturel
readAlt "#" = Diese
readAlt "x" = DoubleDiese

readNote :: String -> Note
readNote noteS = let alteration = if last noteS == '#' || last noteS == 'b' then [last noteS] else ""
                 in Note (readNoteId $ take (length noteS - length alteration) noteS) (readAlt alteration)

type Intervalle = Int
fondamentale    = 0
secondeMineure  = 1
secondeMajeure  = 2
tierceMineure   = 3
tierceMajeure   = 4
quarte          = 5
quinteDim       = 6
quinte          = 7
quinteAug       = 8
sixte           = 9
septiemeMineure = 10
septiemeMajeure = 11

type Accord = ([Int], [Int], Int)
majeur      = ([1, 3, 5], gammeMajeure, 0)     :: Accord
mineur      = ([1, 3, 5], gammeMineure, 0)     :: Accord
septiemeDom = ([5, 7, 2, 4], gammeMajeure, -7) :: Accord
mineur7     = ([1, 3, 5, 7], gammeMineure, 0)  :: Accord
majeur7     = ([1, 3, 5, 7], gammeMajeure, 0)  :: Accord

demiTon = 1
ton = 2
type Gamme = [Intervalle]
gammeMajeure = [0, ton, ton, demiTon, ton, ton, ton, demiTon] :: Gamme
gammeMineure = [0, ton, demiTon, ton, ton, demiTon, ton, ton] :: Gamme

-- Logique

valeur :: Note -> Int
valeur (Note blanche alt)
    | alt == DoubleBemol = blanche - 2
    | alt == Bemol = blanche - 1
    | alt == Naturel = blanche
    | alt == Diese = blanche + 1
    | alt == DoubleDiese = blanche + 2

cumul :: (Num a) => [a] -> [a]
cumul = cumul' 0 where cumul' _ [] = []
                       cumul' s (x:xs) = (x+s):(cumul' (s+x) xs)

construireGamme :: Note -> Gamme -> [(Note, Int)]
construireGamme (Note blancheFond altFond) typeGamme = let notes = map readNote ["Do", "Re", "Mi", "Fa", "Sol", "La", "Si"]
                                                           base = let (ls, rs) = break (\note -> getBlanche note == blancheFond) notes in rs ++ ls
                                                           cumulGamme = cumul typeGamme
                                                       in zip (zipWith alterer base cumulGamme) [1..]
                      where alterer (Note n _) intervalle = head [Note n alt
                                                                 | alt <- [DoubleBemol, Bemol, Naturel, Diese, DoubleDiese]
                                                                 , valeur (Note n alt) `mod` 12 == (valeur (Note blancheFond altFond) + intervalle) `mod` 12]

construireAccord :: Note -> Accord -> [(Note, Int)]
construireAccord fondamentale (degres, gamme, decalage) = let gammeDecalee = let valeurDecalee = (valeur fondamentale + decalage) `mod` 12
                                                                             in if isBlanche valeurDecalee
                                                                                then construireGamme (Note valeurDecalee Naturel) gamme
                                                                                else if elem fondamentale $ map fst (construireGamme (Note (valeurDecalee - 1) Diese) gamme)
                                                                                     then construireGamme (Note (valeurDecalee - 1) Diese) gamme
                                                                                     else construireGamme (Note (valeurDecalee + 1) Bemol) gamme
                                                          in map simplifier $ filter (\(n, d) -> d `elem` degres) gammeDecalee
                      where isBlanche val = val`elem` (map (getBlanche.readNote) $ ["Do", "Re", "Mi", "Fa", "Sol", "La", "Si"])

simplifier :: (Note, Int) -> (Note, Int)
simplifier (note, degre) = (readNote . simplifier' . show $ note, degre)
  where simplifier' "Dob" = "Si"
        simplifier' "Si#" = "Do"
        simplifier' "Fab" = "Mi"
        simplifier' "Mi#" = "Fa"
        simplifier' "Dox" = "Re"
        simplifier' "Rex" = "Mi"
        simplifier' "Fax" = "Sol"
        simplifier' "Solx" = "La"
        simplifier' "Lax" = "Si"
        simplifier' "Rebb" = "Do"
        simplifier' "Mibb" = "Re"
        simplifier' "Solbb" = "Fa"
        simplifier' "Labb" = "Sol"
        simplifier' "Sibb" = "La"
        simplifier' n = n
        
renverser :: Int -> [(Note, Int)] -> [(Note, Int)]
renverser n notes = reverse $ ((reverse $ take nb notes) ++ (take (length notes - nb) $ reverse notes)) where
                nb = n `mod` length notes

parseAndConstruct :: String -> (Note -> a -> [(Note, Int)]) -> (String -> a) -> [(Note, Int)]
parseAndConstruct input constructeur getType = let tailleNote = if length input > 1 && (input !! 1 == '#' || input !! 1 == 'b') then 2 else 1
                                                   tType = getType $ drop tailleNote input
                                               in  constructeur (readNote $ take tailleNote input) tType
      
accord :: String -> [(Note, Int)]
accord accordS = parseAndConstruct accordS construireAccord getAccordType

gamme :: String -> [(Note, Int)]
gamme gammeS = parseAndConstruct gammeS construireGamme getGammeType

getAccordType :: String -> Accord
getAccordType ""   = majeur
getAccordType "m"  = mineur
getAccordType "-"  = mineur
getAccordType "7"  = septiemeDom
getAccordType "m7" = mineur7
getAccordType "-7" = mineur7
getAccordType "M7" = majeur7
getAccordType "maj7" = majeur7

getGammeType :: String -> Gamme
getGammeType ""   = gammeMajeure
getGammeType "m"  = gammeMineure

-- import/export XML

parcourirXML :: [String] -> NTrees XNode -> String
parcourirXML _ [NTree (XText nom) []] = nom
parcourirXML chemin ((NTree (XTag qTag _) deeperTrees):otherTrees) = parcourirXML chemin (if localPart qTag `elem` chemin then deeperTrees else otherTrees)
parcourirXML _ [] = ""

construireXMLNotes :: [String] -> String
construireXMLNotes resultats = unlines $ ["<resultat>"] ++ (map (\r -> "<note>"++r++"</note>") resultats) ++ ["</resultat>"]

traiterRequete :: String -> String
traiterRequete requeteXML = let nomAccord = parcourirXML ["accord", "nom"] . xread . concat . lines $ requeteXML
                                renversement = read $ parcourirXML ["accord", "renversement"] . xread . concat . lines $ requeteXML
                                notes = renverser renversement $ accord nomAccord
                            in construireXMLNotes $ map (show . fst) $ notes

--main = do
--    requeteXML <- getContents
--    putStrLn $ traiterRequete requeteXML

-- Tests unitaires

testAccordMajeur  = ("Accord majeur           ", intercalate " " $ map (show.fst) $ construireAccord (readNote "La") majeur, "La Do# Mi")
testAccordMineur  = ("Accord mineur           ", intercalate " " $ map (show.fst) $ construireAccord (readNote "Do") mineur, "Do Mib Sol")
testAccord7dom    = ("Accord 7e dom           ", intercalate " " $ map (show.fst) $ construireAccord (readNote "Sol") septiemeDom, "Sol Si Re Fa")
testAccord7domb   = ("Accord 7e dom (b )      ", intercalate " " $ map (show.fst) $ construireAccord (readNote "Fa") septiemeDom, "Fa La Do Mib")
testAccord7domD   = ("Accord 7e dom ( #)      ", intercalate " " $ map (show.fst) $ construireAccord (readNote "Fa#") septiemeDom, "Fa# La# Do# Mi")
testAccord7dombb  = ("Accord 7e dom (bb)      ", intercalate " " $ map (show.fst) $ construireAccord (readNote "Re#") septiemeDom, "Re# Sol La# Do#")
testAccord7domDD  = ("Accord 7e dom (##)      ", intercalate " " $ map (show.fst) $ construireAccord (readNote "Mib") septiemeDom, "Mib Sol Sib Reb")
testAccordMineur7 = ("Accord mineur 7e        ", intercalate " " $ map (show.fst) $ construireAccord (readNote "Mi") mineur7, "Mi Sol Si Re")
testAccordMajeur7D= ("Accord majeur 7 (diese) ", intercalate " " $ map (show.fst) $ construireAccord (readNote "Do#") majeur7, "Do# Fa Sol# Do")
testAccordMajeur7b= ("Accord majeur 7 (bemol) ", intercalate " " $ map (show.fst) $ construireAccord (readNote "Reb") majeur7, "Reb Fa Lab Do")
testRenversement  = ("Renversement            ", intercalate " " $ map (show.fst) $ renverser 2 $ construireAccord (readNote "Do#") majeur7, "Sol# Do Do# Fa")
testparseAccordM  = ("Parsing d'accord majeur ", intercalate " " $ map (show.fst) $ accord "C", "Do Mi Sol")
testparseAccordm  = ("Parsing d'accord mineur ", intercalate " " $ map (show.fst) $ accord "Abm", "Lab Si Mib")
testparseAccord7  = ("Parsing d'accord 7e     ", intercalate " " $ map (show.fst) $ accord "G#7", "Sol# Do Re# Fa#")
testparseAccordm7 = ("Parsing d'accord m7     ", intercalate " " $ map (show.fst) $ accord "G#m7", "Sol# Si Re# Fa#")
testparseAccordM7 = ("Parsing d'accord maj7   ", intercalate " " $ map show $ accord "G#maj7", "Sol# Do Re# Sol")
testReadShowNote  = ("Lire/Afficher note      ", intercalate " " $ map show $ [readNote "Mi", readNote "Fa#", readNote "Solb"], "Mi Fa# Solb")
testGammeMajeure  = ("Gamme majeure           ", intercalate " " $ map show $ construireGamme (readNote "Re") gammeMajeure, "Re Mi Fa# Sol La Si Do#")
testParseGammeMaj = ("Parsing de gamme majeure", intercalate " " $ map show $ gamme "D", "Re Mi Fa# Sol La Si Do#")
testParseGammeMin = ("Parsing de gamme mineure", intercalate " " $ map show $ gamme "Gm", "Sol La Sib Do Re Mib Fa")


unitTest = let
              unitTestsAux = unlines $ map (\(nom, test, resultat) -> nom ++ ": " ++ (if test == resultat then "OK" else "FAILED")) [
                 testAccordMajeur
                ,testAccordMineur
                ,testAccord7dom
                ,testAccord7domb
                ,testAccord7domD
                ,testAccord7dombb
                ,testAccord7domDD
                ,testAccordMineur7
                ,testAccordMajeur7D
                ,testAccordMajeur7b
                ,testRenversement
                ,testparseAccordM
                ,testparseAccordm
                ,testparseAccord7
                ,testparseAccordm7
                ,testparseAccordM7
                ,testGammeMajeure
                ,testParseGammeMaj
                ,testParseGammeMin
                ]
           in  putStrLn unitTestsAux
