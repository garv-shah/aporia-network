'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"flutter.js": "6fef97aeca90b426343ba6c5c9dc5d4a",
"favicon.png": "4f23fccd23016fbe0f21ea6d5423653f",
"icons/Icon-192.png": "825f2ddb34b714dcb5d91f7582cd5eeb",
"icons/Icon-maskable-192.png": "825f2ddb34b714dcb5d91f7582cd5eeb",
"icons/Icon-512.png": "aeae4afcc7365462fe497493272c1cc2",
"icons/Icon-maskable-512.png": "aeae4afcc7365462fe497493272c1cc2",
"assets/FontManifest.json": "9aa034dbd0983fe09aa455cd808d1cfb",
"assets/AssetManifest.bin": "556843e5ef6182fa3a5faf685ab4febd",
"assets/assets/app_icon.svg": "5e5f996a4c26f8426baca52b34c044fa",
"assets/assets/full_icon.png": "32812d032fdf3f54a6045df038cf44dc",
"assets/assets/images/editor/level.svg": "104d471e8006c3c0ae6ca2353b336e5b",
"assets/assets/images/editor/resize.svg": "dd54e2463bd5341012739877493ce586",
"assets/assets/images/editor/USD.svg": "01ee41793b65172f8710826787ff3e04",
"assets/assets/images/editor/delete.svg": "1740e5b34c2e57221c6c5b0eb0accb81",
"assets/assets/images/editor/strikethrough.svg": "a0445125daabc70130c052664606cd18",
"assets/assets/images/editor/page.svg": "6541e3dc173f6597228ea5334e29e05e",
"assets/assets/images/editor/restore.svg": "209f6cc4caba39eb301663cff4911155",
"assets/assets/images/editor/comment.svg": "625646a445f75ab35c7db10c7b55f966",
"assets/assets/images/editor/insert_emoticon.svg": "5d004d1de6b128bc5516684a5b42e780",
"assets/assets/images/editor/H3.svg": "8cc45d845f9a47838c0a7f76d589379f",
"assets/assets/images/editor/settings.svg": "533643ed722e090f3294a06d7cd8552d",
"assets/assets/images/editor/duplicate.svg": "259801d4dd93ca919ec5fee37258d3d7",
"assets/assets/images/editor/numbers.svg": "9dad0889a48bb8f0ff288a5c0b711ab4",
"assets/assets/images/editor/timer_finish.svg": "7095efc087930d623d6b68baf9fa4d9e",
"assets/assets/images/editor/tag.svg": "fac4c4f8f3599c18414121d446d65e05",
"assets/assets/images/editor/timer_start.svg": "794f73c9f5752fba0fe2883e6c0f4e08",
"assets/assets/images/editor/person.svg": "37a04d401ddd8b9cfa0b53996723f2df",
"assets/assets/images/editor/tag_block.svg": "998f14c56bab8ce961fdade21a61db65",
"assets/assets/images/editor/image.svg": "92468547c1be63604f0820e565a1a6c2",
"assets/assets/images/editor/add.svg": "90cda25a8cc644d2d1dc415591c7ddc3",
"assets/assets/images/editor/edit.svg": "c71f7f1fce2ea4377890ab49d5985e5f",
"assets/assets/images/editor/H1.svg": "0cf2ed1a92e5efc8638332f32a43ba6c",
"assets/assets/images/editor/copy.svg": "941a7d04c2ff325fd4c3d91b6d4c1b01",
"assets/assets/images/editor/close.svg": "7ee8e3fb110ed225b1631894eeeb1fe9",
"assets/assets/images/editor/more.svg": "8bde02c043e42e63067057a9618ae067",
"assets/assets/images/editor/template.svg": "f8c9ba9bfd1104faa812d9a75143bafe",
"assets/assets/images/editor/time.svg": "809b081a301f761b18c85a85178c7148",
"assets/assets/images/editor/toggle_list.svg": "de3e8bc2d8424a1354693e722dca5934",
"assets/assets/images/editor/date.svg": "ed4d11b11aa9b58f06b2c672414936b0",
"assets/assets/images/editor/details.svg": "18ab4b1143e26a7bbed18a4e091e646f",
"assets/assets/images/editor/option.svg": "100a5be502c1eab01d97d2bff43e9321",
"assets/assets/images/editor/documents.svg": "8a0ce6a1a69ce57c274bb0277f88c3c3",
"assets/assets/images/editor/search.svg": "4211c131baede22302f03ec05d214ef7",
"assets/assets/images/editor/status.svg": "e181c78d684512965114fe2cccd62d14",
"assets/assets/images/editor/list_dropdown.svg": "4a9c145302b103122bebc6978449adc2",
"assets/assets/images/editor/text.svg": "890a3a1b0a674b1fbd769f42520cfef7",
"assets/assets/images/editor/logout.svg": "56f335cf4123850f58f739690a14775d",
"assets/assets/images/editor/grid.svg": "e772c83d6f6d1746f1c8a1f87be9a3c6",
"assets/assets/images/editor/euro.svg": "0c1dd3299f727a27f7821b3d1166722d",
"assets/assets/images/editor/check.svg": "aa2570c03bd73156b55550b0c4f63b27",
"assets/assets/images/editor/import.svg": "be58351fd168ac89c8560437b00fdc49",
"assets/assets/images/editor/report.svg": "d68dd3fd7d392332c8face8185f9e7e1",
"assets/assets/images/editor/math.svg": "ece38554421db5662255c1f961208d04",
"assets/assets/images/editor/drag_element.svg": "36b6e50ccbe175c10febd9b70c6fe28a",
"assets/assets/images/editor/comments.svg": "b8c121f2fdf0cd7ed4b31d391a3fdd85",
"assets/assets/images/editor/pound.svg": "23fd6a96f022e41fdd5116c147853092",
"assets/assets/images/editor/insert_emoticon_2.svg": "038edfe3b52806e0042d686508782f79",
"assets/assets/images/editor/percent.svg": "78e8e4b2aeb0d0043e0a5c75feeab73f",
"assets/assets/images/editor/editor_uncheck.svg": "d94aa89207d28adebb0a4e11237f1c57",
"assets/assets/images/editor/dashboard.svg": "ab38e67bdacf71155780f82d133c6a00",
"assets/assets/images/editor/underline.svg": "0b660e4c7b40f316733bf743add4f109",
"assets/assets/images/editor/slash.svg": "86a4deacc25a8689d22fe52cf89230db",
"assets/assets/images/editor/clear.svg": "9df2adfd584259b3d2c19039c5aa4b9b",
"assets/assets/images/editor/send.svg": "e8394d30cf080585ef56fee6b7e8838d",
"assets/assets/images/editor/checkbox.svg": "b81c986f918f1bd859fe07717b1e9d59",
"assets/assets/images/editor/share.svg": "d323cd62b3df10a342e8e78ca50bf4e1",
"assets/assets/images/editor/editor_check.svg": "c7b016041b6a5b0ce7cd50b7277364ec",
"assets/assets/images/editor/right.svg": "9ab9a261966286cc77817738f7368381",
"assets/assets/images/editor/group.svg": "3f87d37d0b1d4126e0302588f0d8b307",
"assets/assets/images/editor/inline_block.svg": "fadab1e0ea6968928bf21295f48cbc4d",
"assets/assets/images/editor/persoin_1.svg": "4b9b029302e9ef38f5f8e9f6e7523c53",
"assets/assets/images/editor/quote.svg": "f3888b58faf16f6dae129a243819d6f4",
"assets/assets/images/editor/drop_menu/show.svg": "db5606996d0fba48d4f4b5b3bd3ad0ca",
"assets/assets/images/editor/drop_menu/hide.svg": "c4aaa133d371515ca56ecd23bc67e5fe",
"assets/assets/images/editor/link.svg": "d323cd62b3df10a342e8e78ca50bf4e1",
"assets/assets/images/editor/attach.svg": "e888af33a2beb47eaf58a7913e305f70",
"assets/assets/images/editor/italic.svg": "f488b231de192437de4e77fe047ed86f",
"assets/assets/images/editor/messages.svg": "ab9e5f44bdeb147095ac4de628ab6707",
"assets/assets/images/editor/checklist.svg": "1200faa6b06217d769aeab0e02ecf7c8",
"assets/assets/images/editor/color_formatter.svg": "ec1eedd2f966ce3dfa611cdb5003171c",
"assets/assets/images/editor/show_menu.svg": "9939a010ff5c458a61537274d1a2cde7",
"assets/assets/images/editor/left.svg": "e303d62f7a6bef53b112736745db504f",
"assets/assets/images/editor/highlight.svg": "3ab4e3be193362a8a439ee4a4340d908",
"assets/assets/images/editor/full_view.svg": "3cd3d491e2298f46778cd47243aee10c",
"assets/assets/images/editor/align/center.svg": "ae36f4a5833564fbfd0ea3dadcd6e394",
"assets/assets/images/editor/align/right.svg": "c5e4940dd33ddb004614293e37aefa5c",
"assets/assets/images/editor/align/left.svg": "86985fad0c81cdec64c34b8b0bc9111b",
"assets/assets/images/editor/bold.svg": "497734aa4cf4072124bc579125f3bcca",
"assets/assets/images/editor/board.svg": "7ef80dc4af7d603c46a31a765ab283c8",
"assets/assets/images/editor/H2.svg": "6f71aef3145ffbfbd60d55545e5fea85",
"assets/assets/images/editor/bullet_list.svg": "7b22749438c843bc176fb559c924ad21",
"assets/assets/images/editor/hide.svg": "95b626853e0db4d231459b87a6347c37",
"assets/assets/images/editor/calendar.svg": "a5c05815eeff004ecef98d93626a7157",
"assets/assets/images/grid/delete.svg": "df0e3ad80005132abee9f2b5a52b7e1e",
"assets/assets/images/grid/duplicate.svg": "da9acd06797f702d3d4ab4887d2108f6",
"assets/assets/images/grid/clock.svg": "d58beacd628bf6d8c3a4ff2f49104712",
"assets/assets/images/grid/more.svg": "8bde02c043e42e63067057a9618ae067",
"assets/assets/images/grid/details.svg": "18ab4b1143e26a7bbed18a4e091e646f",
"assets/assets/images/grid/right.svg": "9ab9a261966286cc77817738f7368381",
"assets/assets/images/grid/checkmark.svg": "18973e116e9173b0543619ea6f3fcad3",
"assets/assets/images/grid/left.svg": "e303d62f7a6bef53b112736745db504f",
"assets/assets/images/grid/expander.svg": "155b5a56137bf67ccf0ec5f0c75c6a11",
"assets/assets/images/grid/hide.svg": "3d8facd8b87ea02f7d082234b71380af",
"assets/assets/app_icon.png": "4c9aafe98c19ceeefce3590a1bd31235",
"assets/assets/foreground_icon.png": "d508335f20c72a15f1dfe728926a794b",
"assets/assets/aporia_icon.svg": "5e5f996a4c26f8426baca52b34c044fa",
"assets/assets/party-popper.svg": "e7e669fb633ed6c3be33b4348bc8efb1",
"assets/assets/app_icon_desktop.png": "a4d9a5e8f056e287ff91c7f4853cc435",
"assets/AssetManifest.json": "5a045b993ce4038d49ae30e8eadd3251",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "25ff823d86e2b533d14d59570c1afc28",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_Size2-Regular.ttf": "959972785387fe35f7d47dbfb0385bc4",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_Typewriter-Regular.ttf": "87f56927f1ba726ce0591955c8b3b42d",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_Main-BoldItalic.ttf": "e3c361ea8d1c215805439ce0941a1c8d",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_Math-Italic.ttf": "a7732ecb5840a15be39e1eda377bc21d",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_SansSerif-Bold.ttf": "ad0a28f28f736cf4c121bcb0e719b88a",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_SansSerif-Italic.ttf": "d89b80e7bdd57d238eeaa80ed9a1013a",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_AMS-Regular.ttf": "657a5353a553777e270827bd1630e467",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_Caligraphic-Regular.ttf": "7ec92adfa4fe03eb8e9bfb60813df1fa",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_Script-Regular.ttf": "55d2dcd4778875a53ff09320a85a5296",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_Main-Italic.ttf": "ac3b1882325add4f148f05db8cafd401",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_Fraktur-Regular.ttf": "dede6f2c7dad4402fa205644391b3a94",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_Main-Bold.ttf": "9eef86c1f9efa78ab93d41a0551948f7",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_SansSerif-Regular.ttf": "b5f967ed9e4933f1c3165a12fe3436df",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_Main-Regular.ttf": "5a5766c715ee765aa1398997643f1589",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_Caligraphic-Bold.ttf": "a9c8e437146ef63fcd6fae7cf65ca859",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_Size4-Regular.ttf": "85554307b465da7eb785fd3ce52ad282",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_Fraktur-Bold.ttf": "46b41c4de7a936d099575185a94855c4",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_Size1-Regular.ttf": "1e6a3368d660edc3a2fbbe72edfeaa85",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_Size3-Regular.ttf": "e87212c26bb86c21eb028aba2ac53ec3",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_Math-BoldItalic.ttf": "946a26954ab7fbd7ea78df07795a6cbc",
"assets/packages/timezone/data/latest_all.tzf": "871b8008607c14f36bae2388a95fdc8c",
"assets/packages/math_keyboard/fonts/CustomKeyIcons.ttf": "704ec8c6003ba0ba02551368d2a39e4c",
"assets/packages/appflowy_editor/assets/images/delete.svg": "4a8d17ccc8cd1bd44a472f66ad028a01",
"assets/packages/appflowy_editor/assets/images/point.svg": "50c7d9067a4a84945f1d79640589f501",
"assets/packages/appflowy_editor/assets/images/copy.svg": "8aff328e13b4b3667a6fbe1046d691b2",
"assets/packages/appflowy_editor/assets/images/check.svg": "c7b016041b6a5b0ce7cd50b7277364ec",
"assets/packages/appflowy_editor/assets/images/uncheck.svg": "d94aa89207d28adebb0a4e11237f1c57",
"assets/packages/appflowy_editor/assets/images/toolbar/center.svg": "978236ba1b8cb0882d8f5e29a5ceaef1",
"assets/packages/appflowy_editor/assets/images/toolbar/strikethrough.svg": "82564a24aa7e82675d377431ac8fb075",
"assets/packages/appflowy_editor/assets/images/toolbar/h2.svg": "bf7b09c579a5db9e6392b01f95909347",
"assets/packages/appflowy_editor/assets/images/toolbar/numbered_list.svg": "a6072f727ea30c379dd5e0e2909790c4",
"assets/packages/appflowy_editor/assets/images/toolbar/text.svg": "2b52bcda2b12945b27e859c414ef43c9",
"assets/packages/appflowy_editor/assets/images/toolbar/code.svg": "2d41f509ac1e1b1eb60c9adedc75ce03",
"assets/packages/appflowy_editor/assets/images/toolbar/underline.svg": "fc86b2c49c42f5b9322a4ba76d066203",
"assets/packages/appflowy_editor/assets/images/toolbar/right.svg": "bf18d4c1654d502abea1d2c8aa010c30",
"assets/packages/appflowy_editor/assets/images/toolbar/text_color.svg": "5943cc2453a095c8e49f0bb6ab4c0177",
"assets/packages/appflowy_editor/assets/images/toolbar/highlight_color.svg": "df1b842dc7d37edeec995512e543b598",
"assets/packages/appflowy_editor/assets/images/toolbar/quote.svg": "7d20ee07b7f80cc886294a43a0db0b3d",
"assets/packages/appflowy_editor/assets/images/toolbar/link.svg": "42aee34d22fd39e710e4e448bf654e29",
"assets/packages/appflowy_editor/assets/images/toolbar/h3.svg": "30d4699894d5de3b696b11cf678b35a0",
"assets/packages/appflowy_editor/assets/images/toolbar/italic.svg": "b96a655409eea41190182ae3ab3ed500",
"assets/packages/appflowy_editor/assets/images/toolbar/left.svg": "fcd2f1a9124961798dd7009f27172a64",
"assets/packages/appflowy_editor/assets/images/toolbar/h1.svg": "735f59f34690e55680453a0d018ada75",
"assets/packages/appflowy_editor/assets/images/toolbar/bold.svg": "51e86ea040233e6a093caf02eea0c5f4",
"assets/packages/appflowy_editor/assets/images/toolbar/divider.svg": "b7677e94ef1007c39a1853588b177d1e",
"assets/packages/appflowy_editor/assets/images/toolbar/bulleted_list.svg": "b9441734387d7df0122b9dc629ca6bbb",
"assets/packages/appflowy_editor/assets/images/selection_menu/number.svg": "9dad0889a48bb8f0ff288a5c0b711ab4",
"assets/packages/appflowy_editor/assets/images/selection_menu/h2.svg": "129cb4e93b4badba4805968b13d52098",
"assets/packages/appflowy_editor/assets/images/selection_menu/image.svg": "92468547c1be63604f0820e565a1a6c2",
"assets/packages/appflowy_editor/assets/images/selection_menu/text.svg": "890a3a1b0a674b1fbd769f42520cfef7",
"assets/packages/appflowy_editor/assets/images/selection_menu/checkbox.svg": "b81c986f918f1bd859fe07717b1e9d59",
"assets/packages/appflowy_editor/assets/images/selection_menu/quote.svg": "f58d378109520a8058edb4fed9d9ddbb",
"assets/packages/appflowy_editor/assets/images/selection_menu/h3.svg": "cd75480a77da1cabc7c5c2bf81325322",
"assets/packages/appflowy_editor/assets/images/selection_menu/h1.svg": "8135d2d5883f5cdd8776dca2dddb5f9b",
"assets/packages/appflowy_editor/assets/images/selection_menu/bulleted_list.svg": "7b22749438c843bc176fb559c924ad21",
"assets/packages/appflowy_editor/assets/images/clear.svg": "f74736135d3ee5656b916262104469d0",
"assets/packages/appflowy_editor/assets/images/clear_highlight_color.svg": "0b35a31822656c53578fb91acdfacb31",
"assets/packages/appflowy_editor/assets/images/reset_text_color.svg": "a9ecce95365f0b4636ad43cc054d87e4",
"assets/packages/appflowy_editor/assets/images/checkmark.svg": "3dc55867deb579484c5702a79054bb0e",
"assets/packages/appflowy_editor/assets/images/quote.svg": "ba6e97b8ddde8bf842fe2a56d06003ad",
"assets/packages/appflowy_editor/assets/images/link.svg": "d323cd62b3df10a342e8e78ca50bf4e1",
"assets/packages/appflowy_editor/assets/images/image_toolbar/delete.svg": "15cbb502f4554ee7a443207099cc839a",
"assets/packages/appflowy_editor/assets/images/image_toolbar/copy.svg": "8aff328e13b4b3667a6fbe1046d691b2",
"assets/packages/appflowy_editor/assets/images/image_toolbar/align_right.svg": "bf18d4c1654d502abea1d2c8aa010c30",
"assets/packages/appflowy_editor/assets/images/image_toolbar/share.svg": "42aee34d22fd39e710e4e448bf654e29",
"assets/packages/appflowy_editor/assets/images/image_toolbar/align_center.svg": "e82165a5f6fb20a7ad3a6faf0ab735cc",
"assets/packages/appflowy_editor/assets/images/image_toolbar/align_left.svg": "fcd2f1a9124961798dd7009f27172a64",
"assets/packages/appflowy_editor/assets/images/image_toolbar/divider.svg": "b7677e94ef1007c39a1853588b177d1e",
"assets/packages/appflowy_editor/assets/images/upload_image.svg": "67fac764479d7cded5e98f6fe58c75ef",
"assets/packages/appflowy_editor/assets/mobile/toolbar_icons/strikethrough.svg": "c82d154453ef6759daa7cebb397cf58c",
"assets/packages/appflowy_editor/assets/mobile/toolbar_icons/h2.svg": "88278b54319f416c66c1cf830fcf6c42",
"assets/packages/appflowy_editor/assets/mobile/toolbar_icons/numbered_list.svg": "1daa60662c6ab43e65ac96e9e930b745",
"assets/packages/appflowy_editor/assets/mobile/toolbar_icons/text_decoration.svg": "e4dd4997dec353c1eb7cdfab039a49ef",
"assets/packages/appflowy_editor/assets/mobile/toolbar_icons/close.svg": "aa945f43dcd92bce9b5c810eb33940be",
"assets/packages/appflowy_editor/assets/mobile/toolbar_icons/list.svg": "ed5fb52546835a9865541c1e2c06c20c",
"assets/packages/appflowy_editor/assets/mobile/toolbar_icons/code.svg": "02ef07d8ea084d72dc2f4cc74a1b756d",
"assets/packages/appflowy_editor/assets/mobile/toolbar_icons/underline.svg": "472439a97df9c883661d818045a40d95",
"assets/packages/appflowy_editor/assets/mobile/toolbar_icons/checkbox.svg": "eda1fb784a3429e96b42b7f24b7ea4c9",
"assets/packages/appflowy_editor/assets/mobile/toolbar_icons/quote.svg": "dda6772a0e0d9b40e8aad07ff377ffc1",
"assets/packages/appflowy_editor/assets/mobile/toolbar_icons/link.svg": "d7a05e0d3a904118900ca7d8e3cf47b4",
"assets/packages/appflowy_editor/assets/mobile/toolbar_icons/h3.svg": "ba38c1cdee5d41663df86128b73b835e",
"assets/packages/appflowy_editor/assets/mobile/toolbar_icons/heading.svg": "8e872c0f97c1740a2f9858523aeb7743",
"assets/packages/appflowy_editor/assets/mobile/toolbar_icons/italic.svg": "c8585c2f19414f94f26430e8eecc4bb3",
"assets/packages/appflowy_editor/assets/mobile/toolbar_icons/color.svg": "d061328f2a2b335e121c44dccff39a43",
"assets/packages/appflowy_editor/assets/mobile/toolbar_icons/h1.svg": "295c462eeb57150f11a2e747d9220869",
"assets/packages/appflowy_editor/assets/mobile/toolbar_icons/bold.svg": "7118c4686f95cedaa776faf7924c89a0",
"assets/packages/appflowy_editor/assets/mobile/toolbar_icons/divider.svg": "098194a544d649f3545d35f301b0191f",
"assets/packages/appflowy_editor/assets/mobile/toolbar_icons/bulleted_list.svg": "4d7dba759b6073003a84e5938aa043b2",
"assets/packages/appflowy_editor/assets/mobile/toolbar_icons/setting.svg": "0cb728ff605b6f7457950f3a47d291f1",
"assets/fonts/MaterialIcons-Regular.otf": "3741e8543257ae9f327e358b408233ff",
"assets/NOTICES": "127f4407744dc28578ecc8c4a3258774",
"assets/shaders/ink_sparkle.frag": "f8b80e740d33eb157090be4e995febdf",
"index.html": "5b0f6e43d5177b98ad36890ef4d4ea86",
"/": "5b0f6e43d5177b98ad36890ef4d4ea86",
"main.dart.js": "d306f0c3f39ee4ce9b86c3c5d764f895",
"version.json": "cec16ff7f5b79ec609cbc35ceac9ccfa",
"splash/style.css": "bf609973f0fb089fd209aeb4b2408dd7",
"splash/img/dark-2x.png": "24eb3d8d7e6c375b5494fbf4f78d5a74",
"splash/img/dark-3x.png": "cd29a469dee2bc4c7af598445e888a61",
"splash/img/light-3x.png": "cd29a469dee2bc4c7af598445e888a61",
"splash/img/light-2x.png": "efa2182ec30530f81e25f3de2ad06b4f",
"splash/img/dark-1x.png": "05d5030a1a08da5fdbe347555e0662b7",
"splash/img/light-1x.png": "05d5030a1a08da5fdbe347555e0662b7",
"splash/img/dark-4x.png": "af1c7f2008b119ee30e086bbddc14124",
"splash/img/light-4x.png": "2393325a07be93d34f54d445e472271e",
"splash/splash.js": "123c400b58bea74c1305ca3ac966748d",
"canvaskit/skwasm.js": "95f16c6690f955a45b2317496983dbe9",
"canvaskit/chromium/canvaskit.wasm": "be0e3b33510f5b7b0cc76cc4d3e50048",
"canvaskit/chromium/canvaskit.js": "96ae916cd2d1b7320fff853ee22aebb0",
"canvaskit/canvaskit.wasm": "42df12e09ecc0d5a4a34a69d7ee44314",
"canvaskit/skwasm.wasm": "1a074e8452fe5e0d02b112e22cdcf455",
"canvaskit/canvaskit.js": "bbf39143dfd758d8d847453b120c8ebb",
"canvaskit/skwasm.worker.js": "51253d3321b11ddb8d73fa8aa87d3b15"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"assets/AssetManifest.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
