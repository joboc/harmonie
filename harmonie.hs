import Data.List

-- Musical data

data Alteration = Bemol | Naturel | Sharp
data Note = Note Integer Alteration

showNoteId 0 = "Do"
showNoteId 1 = "Re"
showNoteId 2 = "Mi"
showNoteId 3 = "Fa"
showNoteId 4 = "Sol"
showNoteId 5 = "La"
showNoteId 6 = "Si"
showAlt Bemol   = "b"
showAlt Naturel = ""
showAlt Sharp   = "#"

instance Show Note where
    show (Note n a) = showNoteId n ++ showAlt a

readNoteId "Do"  = 0
readNoteId "Re"  = 1
readNoteId "Mi"  = 2
readNoteId "Fa"  = 3
readNoteId "Sol" = 4
readNoteId "La"  = 5
readNoteId "Si"  = 6
readAlt "b" = Bemol
readAlt ""  = Naturel
readAlt "#" = Sharp

readNote :: String -> Note
readNote noteS = let alteration = if last noteS == '#' || last noteS == 'b' then [last noteS] else ""
                 in Note (readNoteId $ take (length noteS - length alteration) noteS) (readAlt alteration)

{--
readNote :: String -> Note
readNote "Do"   =  Note 0
readNote "Do#"  =  Note 1
readNote "Reb"  =  Note 1
readNote "Re"   =  Note 2
readNote "Re#"  =  Note 3
readNote "Mib"  =  Note 3
readNote "Mi"   =  Note 4
readNote "Fa"   =  Note 5
readNote "Fa#"  =  Note 6
readNote "Solb" =  Note 6
readNote "Sol"  =  Note 7
readNote "Sol#" =  Note 8
readNote "Lab"  =  Note 8
readNote "La"   =  Note 9
readNote "La#"  =  Note 10
readNote "Sib"  =  Note 10
readNote "Si"   =  Note 11

readNote "C"    =  Note 0
readNote "C#"   =  Note 1
readNote "Db"   =  Note 1
readNote "D"    =  Note 2
readNote "D#"   =  Note 3
readNote "Eb"   =  Note 3
readNote "E"    =  Note 4
readNote "F"    =  Note 5
readNote "F#"   =  Note 6
readNote "Gb"   =  Note 6
readNote "G"    =  Note 7
readNote "G#"   =  Note 8
readNote "Ab"   =  Note 8
readNote "A"    =  Note 9
readNote "A#"   =  Note 10
readNote "Bb"   =  Note 10
readNote "B"    =  Note 11
--}

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

decaler :: Note -> Intervalle -> Note
decaler (Note n) intervalle = Note ((n+intervalle) `mod` 12)

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
