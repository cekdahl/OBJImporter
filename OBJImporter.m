BeginPackage["OBJImporter`"]

Begin["`Private`"]


(*--------------------- Parse .mtl files ---------------------*)
materialDefaults = <|
    "Name" -> "",
    "AmbientColor" -> RGBColor[{0.2, 0.2, 0.2}],
    "DiffuseColor" -> RGBColor[0.8, 0.8, 0.8],
    "SpecularColor" -> RGBColor[{1, 1, 1}],
    "SpecularExponent" -> 0,
    "SpecularHighlights" -> False,
    "Opacity" -> 1,
    "Texture" -> None
    |>;

commentQ = StringMatchQ["#" ~~ ___];
newmtlQ = StringMatchQ["newmtl" ~~ Whitespace ~~ __];
ambientColorQ = StringMatchQ["Ka" ~~ Repeated[Whitespace .. ~~ NumberString, 3]];
diffuseColorQ = StringMatchQ["Kd" ~~ Repeated[Whitespace .. ~~ NumberString, 3]];
specularColorQ = StringMatchQ["Ks" ~~ Repeated[Whitespace .. ~~ NumberString, 3]];
nonTransparencyQ = StringMatchQ["d" ~~ Whitespace ~~ NumberString];
transparencyQ = StringMatchQ["Tr" ~~ Whitespace ~~ NumberString];
specularExponentQ = StringMatchQ["Ns" ~~ Whitespace ~~ NumberString];
specularHighlightsQ = StringMatchQ["illum" ~~ Whitespace ~~ "1" | "2"];
textureQ = StringMatchQ[("map_Ka" | "map_Kd") ~~ Whitespace ~~ __];

parseMTL[MTLs_, line_?newmtlQ] := Append[MTLs, <|materialDefaults, "Name" -> StringExtract[line, 2]|>]
parseMTL[{prevMTL___, MTL_}, line_?ambientColorQ] := {prevMTL, <|
    MTL,
    "AmbientColor" -> RGBColor[ToExpression@StringExtract[line, 2 ;; 4]]
    |>}
parseMTL[{prevMTL___, MTL_}, line_?diffuseColorQ] := {prevMTL, <|
    MTL,
    "DiffuseColor" -> RGBColor[ToExpression@StringExtract[line, 2 ;; 4]]
    |>}
parseMTL[{prevMTL___, MTL_}, line_?specularColorQ] := {prevMTL, <|
    MTL,
    "SpecularColor" -> RGBColor[ToExpression@StringExtract[line, 2 ;; 4]]
    |>}
parseMTL[{prevMTL___, MTL_}, line_?specularExponentQ] := {prevMTL, <|
    MTL,
    "SpecularExponent" -> ToExpression@StringExtract[line, 2]
    |>}
parseMTL[{prevMTL___, MTL_}, line_?nonTransparencyQ] := {prevMTL, <|
    MTL,
    "Opacity" -> ToExpression@StringExtract[line, 2]
    |>}
parseMTL[{prevMTL___, MTL_}, line_?transparencyQ] := {prevMTL, <|
    MTL,
    "Opacity" -> 1 - ToExpression@StringExtract[line, 2]
    |>}
parseMTL[{prevMTL___, MTL_}, line_?specularHighlightsQ] := {prevMTL, <|
    MTL,
    "SpecularHighlights" -> StringMatchQ[line, "illum 2"]
    |>}
parseMTL[{prevMTL___, MTL_}, line_?textureQ] := {prevMTL, <|
    MTL,
    "Texture" -> StringExtract[line, 2]
    |>}
parseMTL[MTLs_, line_] := MTLs

(*--------------------- Parse .obj files ---------------------*)
objectDefaults = <|
    "GroupName" -> "",
    "SmoothingGroup" -> 0,
    "Material" -> "",
    "FaceList" -> {}
    |>;

vertexQ = StringMatchQ["v" ~~ Repeated[Whitespace .. ~~ NumberString, {3, 4}]];
textureCoordinateQ = StringMatchQ["vt" ~~ Repeated[Whitespace .. ~~ NumberString, {2, 3}]];
faceNormalQ = StringMatchQ["vn" ~~ Repeated[Whitespace .. ~~ NumberString, 3]];
faceVertexSpec = Alternatives[
  DigitCharacter ..,
  DigitCharacter .. ~~ "/" ~~ DigitCharacter ..,
  DigitCharacter .. ~~ "/" ~~ DigitCharacter ... ~~ "/" ~~ DigitCharacter ..
];
faceQ = StringMatchQ["f" ~~ Repeated[Whitespace .. ~~ faceVertexSpec, {3, Infinity}]];
mtllibQ = StringMatchQ["mtllib" ~~ Whitespace ~~ __];
objectNameQ = StringMatchQ["o" ~~ Whitespace ~~ __];
groupNameQ = StringMatchQ["g" ~~ Whitespace ~~ __];
usemtlQ = StringMatchQ["usemtl" ~~ Whitespace ~~ __];
smoothingGroupQ = StringMatchQ["s" ~~ Whitespace ~~ DigitCharacter ..];

parseFaceList[groupList_, material_?usemtlQ] := Append[groupList, <|objectDefaults, "Material" -> StringExtract[material, 2]|>]
parseFaceList[{prevGroups___, group_}, smoothingGroup_?smoothingGroupQ] := {prevGroups, <|
    group,
    "SmoothingGroup" -> StringExtract[smoothingGroup, 2]
    |>}
parseFaceList[{prevGroups___, group_}, groupName_?groupNameQ] := {prevGroups, <|
    group,
    "GroupName" -> StringExtract[groupName, 2]
    |>}
parseFaceList[{prevGroups___, group_}, face_?faceQ] := {prevGroups, <|
    group,
    "FaceList" -> Append[
      group["FaceList"],
      ToExpression@StringCases[face, {
        Whitespace .. ~~ v : DigitCharacter .. ~~ "/" ~~ vt : DigitCharacter ... ~~ "/" ~~ vn : DigitCharacter .. :> {v, vt, vn},
        Whitespace .. ~~ v : DigitCharacter .. ~~ "/" ~~ vt : DigitCharacter .. :> {v, vt, 0},
        Whitespace .. ~~ v : DigitCharacter .. :> {v, 0, 0}
      }]
    ]
    |>}
parseFaceList[groups_, _] := groups

parseVertexCoordinates[vertices_, vertex_?vertexQ] := Append[
  vertices,
  PadRight[ToExpression@StringExtract[vertex, 2 ;;], 3]
]
parseVertexCoordinates[vertices_, _] := vertices

parseTextureCoordinates[textureCoordinates_, coordinate_?textureCoordinateQ] := Append[
  textureCoordinates,
  PadRight[ToExpression@StringExtract[coordinate, 2 ;;], 3]
]
parseTextureCoordinates[textureCoordinates_, _] := textureCoordinates

parseFaceNormals[faceNormals_, faceNormal_?faceNormalQ] := Append[
  faceNormals,
  ToExpression@StringExtract[faceNormal, {2, 3, 4}]
]
parseFaceNormals[faceNormals_, _] := faceNormals

findMTLFile[accepted_, candidate_] := If[
  StringMatchQ[candidate, "mtllib" ~~ Whitespace ~~ __],
  StringRiffle@StringExtract[candidate, 2;;],
  accepted
]
findMTLFile[obj_] := Fold[findMTLFile, None, obj]

(*--------------------- Turn specifications into graphics directives and primitives ---------------------*)
buildStyleDirective[mtlspecs_, dir_] := Directive[
  mtlspecs["DiffuseColor"],
  Glow[mtlspecs["AmbientColor"]],
  If[
    mtlspecs["SpecularHighlights"],
    Specularity[mtlspecs["SpecularColor"], mtlspecs["SpecularExponent"]], ## &[]
  ],
  Opacity[mtlspecs["Opacity"]],
  If[
    mtlspecs["Texture"] =!= None,
    Texture[Import[dir <> mtlspecs["Texture"]]], ## &[]
  ]
]

buildPolygon[faceList_, vertexCoordinatesList_, textureCoordinatesList_, faceNormalsList_] := Module[
  {indices, uniqueIndices, vertexIndices, textureIndices, faceNormalsIndices, gcIndices, rules, gc},
  indices = Flatten[faceList, 1];
  uniqueIndices = DeleteDuplicates[indices];
  {vertexIndices, textureIndices, faceNormalsIndices} = DeleteCases[0] /@ Transpose[uniqueIndices];
  rules = Thread[uniqueIndices -> Range@Length@uniqueIndices];
  gc = GraphicsComplex[
    vertexCoordinatesList[[vertexIndices]],
    Polygon[faceList /. rules]
  ];
  If[
    Length[textureIndices] > 0,
    AppendTo[gc, VertexTextureCoordinates -> textureCoordinatesList[[textureIndices]]]
  ];
  If[
    Length[faceNormalsIndices] > 0,
    AppendTo[gc, VertexNormals -> faceNormalsList[[faceNormalsIndices ]]]
  ];
  gc
]

buildObject[spec_, mtlspecs_, dir_, vertexCoordinatesList_, textureCoordinatesList_, faceNormalsList_] := Module[{},
  selectedSpecs = SelectFirst[mtlspecs, #Name == spec["Material"] &];
  If[
    MatchQ[selectedSpecs, _Missing],
    Message[Import::mtlspecnf, spec["Material"]], {
      buildStyleDirective[selectedSpecs, dir],
      buildPolygon[spec["FaceList"], vertexCoordinatesList, textureCoordinatesList, faceNormalsList]
    }
  ]
]

(*--------------------- Register importer ---------------------*)

Import::mtlnf = "MTL file `1` not found during Import.";
Import::texturenf = "Texture file `1` not found during Import.";
Import::mtlspecnf = "Material `1` is undefined.";

importOBJ[file_] := Module[
  {obj, dir, mtlSpecs, mtlFile, mtls, textures,
    vertexCoordinates, textureCoordinates, faceNormals, primitives},

  If[
    !FileExistsQ[file],
    Message[Import::nffil, "Import"];
    Return[$Failed]
  ];

  obj = Map[
    StringTrim@StringReplace[#, first___ ~~ "#" ~~ ___ :> first] &,
    Import[file, "Lines"]
  ];

  dir = FileNameDrop[file, -1] <> "/";

  mtlFile = findMTLFile[obj];
  If[!FileExistsQ[dir <> mtlFile], Message[Import::mtlnf, mtlFile]; Return[$Failed]];

  mtlSpecs = {materialDefaults};
  If[
    mtlFile =!= None && FileExistsQ[dir <> mtlFile],
    mtls = Map[
      StringTrim@StringReplace[#, first___ ~~ "#" ~~ ___ :> first] &,
      Import[dir <> mtlFile, "Lines"]
    ];
    mtlSpecs = Fold[parseMTL, {}, mtls];
  ];
  textures = DeleteCases[mtlSpecs[[All, "Texture"]], None];

  Do[
    If[
      !FileExistsQ[dir <> texture],
      Message[Import::texturenf, texture]
      ],
      {texture, textures}
    ];

  vertexCoordinates = Fold[parseVertexCoordinates, {}, obj];
  textureCoordinates = Fold[parseTextureCoordinates, {}, obj];
  faceNormals = Fold[parseFaceNormals, {}, obj];

  primitives = Map[
    buildObject[#, mtlSpecs, dir, vertexCoordinates, textureCoordinates, faceNormals] &,
    Fold[parseFaceList, {}, obj]
  ];

  Graphics3D[{EdgeForm[], primitives}, Boxed -> False]
];

ImportExport`RegisterImport["RawOBJ", importOBJ]

End[]
EndPackage[]