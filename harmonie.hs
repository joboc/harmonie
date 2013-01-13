import Data.List

-- Musical data

data Alteration = Bemol | Naturel | Diese deriving Eq

data Note = Note Integer Alteration

showNoteId 0 = "Do"
showNoteId 2 = "Re"
showNoteId 4 = "Mi"
showNoteId 5 = "Fa"
showNoteId 7 = "Sol"
showNoteId 9 = "La"
showNoteId 11 = "Si"
showAlt Bemol   = "b"
showAlt Naturel = ""
showAlt Diese   = "#"

instance Show Note where
    show (Note n a) = showNoteId n ++ showAlt a

readNoteId "Do"  = 0
readNoteId "Re"  = 2
readNoteId "Mi"  = 4
readNoteId "Fa"  = 5
readNoteId "Sol" = 7
readNoteId "La"  = 9
readNoteId "Si"  = 11
readAlt "b" = Bemol
readAlt ""  = Naturel
readAlt "#" = Diese

readNote :: String -> Note
readNote noteS = let alteration = if last noteS == '#' || last noteS == 'b' then [last noteS] else ""
                 in Note (readNoteId $ take (length noteS - length alteration) noteS) (readAlt alteration)

type Intervalle = Integer
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

majeur      = [fondamentale, tierceMajeure, quinte]
mineur      = [fondamentale, tierceMineure, quinte]
septiemeDom = [fondamentale, tierceMajeure, quinte, septiemeMineure]
mineur7     = [fondamentale, tierceMineure, quinte, septiemeMineure]
majeur7     = [fondamentale, tierceMajeure, quinte, septiemeMajeure]

-- Logique

isBlancheId n = n == 0 || n == 2 || n == 4 || n == 5 || n == 7 || n == 9 || n == 11

decaler :: Note -> Intervalle -> Note
decaler (Note n alt) intervalle = let arriveeId = (n+intervalle) `mod` 12
                                  in if isBlancheId arriveeId
                                     then Note arriveeId Naturel
                                     else if alt == Diese then Note (arriveeId-1) Diese else Note (arriveeId+1) Bemol
{--
decaler :: Note -> Intervalle -> Note
decaler (Note n) intervalle = Note ((n+intervalle) `mod` 12)
--}

construireAccord :: Note -> [Intervalle] -> [Note]
construireAccord fondamentale intervalles = map (decaler fondamentale) intervalles

renverser :: Int -> [Note] -> [Note]
renverser n notes = reverse $ ((reverse $ take nb notes) ++ (take (length notes - nb) $ reverse notes)) where
                nb = n `mod` length notes

accord :: String -> [Note]
accord accordS = let tailleNote = if length accordS > 1 && (accordS !! 1 == '#' || accordS !! 1 == 'b') then 2 else 1
                     accordType = getAccordType $ drop tailleNote accordS
                 in  construireAccord (readNote $ take tailleNote accordS) accordType
                      where getAccordType ""   = majeur
                            getAccordType "m"  = mineur
                            getAccordType "-"  = mineur
                            getAccordType "7"  = septiemeDom
                            getAccordType "m7" = mineur7
                            getAccordType "-7" = mineur7
                            getAccordType "M7" = majeur7
                            getAccordType "maj7" = majeur7
      
-- Tests unitaires

testAccordMajeur  = ("Accord majeur           ", intercalate " " $ map show $ construireAccord (readNote "La") majeur, "La Do# Mi")
testAccordMineur  = ("Accord mineur           ", intercalate " " $ map show $ construireAccord (readNote "Si") mineur, "Si Re Fa#")
testAccord7dom    = ("Accord 7e dom           ", intercalate " " $ map show $ construireAccord (readNote "Sol") septiemeDom, "Sol Si Re Fa")
testAccordMineur7 = ("Accord mineur 7e        ", intercalate " " $ map show $ construireAccord (readNote "Mi") mineur7, "Mi Sol Si Re")
testAccordMajeur7 = ("Accord majeur 7         ", intercalate " " $ map show $ construireAccord (readNote "Do#") majeur7, "Do# Fa Lab Do")
testRenversement  = ("Renversement            ", intercalate " " $ map show $ renverser 2 $ construireAccord (readNote "Do#") majeur7, "Lab Do Do# Fa")
testparseAccordM  = ("Parsing d'accord majeur ", intercalate " " $ map show $ accord "C", "Do Mi Sol")
testparseAccordm  = ("Parsing d'accord mineur ", intercalate " " $ map show $ accord "Abm", "Lab Si Mib")
testparseAccord7  = ("Parsing d'accord 7e     ", intercalate " " $ map show $ accord "G#7", "Lab Do Mib Fa#")
testparseAccordm7 = ("Parsing d'accord m7     ", intercalate " " $ map show $ accord "G#m7", "Lab Si Mib Fa#")
testparseAccordM7 = ("Parsing d'accord maj7   ", intercalate " " $ map show $ accord "G#maj7", "Lab Do Mib Sol")
testReadShowNote  = ("Lire/Afficher note      ", intercalate " " $ map show $ [readNote "Mi", readNote "Fa#", readNote "Solb"], "Mi Fa# Solb")


unitTest = let
              unitTestsAux = unlines $ map (\(nom, test, resultat) -> nom ++ ": " ++ (if test == resultat then "OK" else "FAILED")) [
                 testAccordMajeur
                ,testAccordMineur 
                ,testAccord7dom 
                ,testAccordMineur7
                ,testAccordMajeur7
                ,testRenversement
                ,testparseAccordM
                ,testparseAccordm
                ,testparseAccord7
                ,testparseAccordm7
                ,testparseAccordM7
                ]
           in  putStrLn unitTestsAux
