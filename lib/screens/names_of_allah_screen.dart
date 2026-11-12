// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/theme_manager.dart';
import '../widgets/common/auto_scroll_text.dart';
import 'tasbih_screen.dart';

class NameOfAllah {
  final String name;
  final String meaning;
  final String description;

  const NameOfAllah({
    required this.name,
    required this.meaning,
    required this.description,
  });
}

class NamesOfAllahScreen extends StatefulWidget {
  const NamesOfAllahScreen({super.key});

  @override
  State<NamesOfAllahScreen> createState() => _NamesOfAllahScreenState();
}

class _NamesOfAllahScreenState extends State<NamesOfAllahScreen> {
  String _searchQuery = '';

  static const List<NameOfAllah> _names = [
    NameOfAllah(
        name: 'الرحمن',
        meaning: 'الواسع الرحمة بخلقه جميعاً مؤمنهم وكافرهم',
        description:
            'الذي عمّت رحمته جميع الخلائق في رزقهم ومعاشهم وأسباب حياتهم.'),
    NameOfAllah(
        name: 'الرحيم',
        meaning: 'المنعم بالرحمة الخاصة بعباده المؤمنين',
        description:
            'الذي يرحم المؤمنين في الدنيا بتوفيقهم للطاعة، وفي الآخرة بإدخالهم الجنة.'),
    NameOfAllah(
        name: 'الملك',
        meaning: 'المتصرف في ملكه كيف يشاء بلا منازع',
        description:
            'صاحب السلطان المطلق والملك الكامل الذي يدبر أمر كل شيء في الكون.'),
    NameOfAllah(
        name: 'القدوس',
        meaning: 'المنزه عن كل نقص وعيب وشبيه',
        description:
            'المطهر من الصاحبة والولد، والمنزه عن صفات المخلوقين بالكامل.'),
    NameOfAllah(
        name: 'السلام',
        meaning: 'ناشر السلام والأمان والمنزه عن العيوب',
        description:
            'الذي تسلم ذاته من النقص، ويسلم عباده الصالحون من عقابه في الآخرة.'),
    NameOfAllah(
        name: 'المؤمن',
        meaning: 'واهب الأمان لعباده والصدق في وعده',
        description:
            'الذي يؤمن عباده من الخوف والظلم، ويصدق في وعده وجزائه للمطيعين.'),
    NameOfAllah(
        name: 'المهيمن',
        meaning: 'المسيطر والمراقب لكل صغيرة وكبيرة',
        description:
            'الرقيب الحافظ الشاهد على خلقه، القائم على شؤونهم ورزقهم وأعمالهم.'),
    NameOfAllah(
        name: 'العزيز',
        meaning: 'القوي الغالب الذي لا يغلبه شيء',
        description:
            'الذي لا يُنال شأنه، الغالب على أمره، المنيع في سلطانه وجلاله.'),
    NameOfAllah(
        name: 'الجبار',
        meaning: 'الذي يجبر كسر الضعيف والمنفذ أمره',
        description:
            'الذي يقهر الجبابرة بسلطانه، ويجبر الكسير ويغني الفقير برحمته.'),
    NameOfAllah(
        name: 'المتكبر',
        meaning: 'صاحب الكبرياء والعظمة والمنزه عن السوء',
        description:
            'الذي يتكبر عن سوء خلقه وظلم عباده، المتفرد بصفات العظمة والجلال.'),
    NameOfAllah(
        name: 'الخالق',
        meaning: 'الموجد للمخلوقات من العدم بلا مثال سابق',
        description:
            'الذي أوجد الكائنات بقدرته، وصمم نظامها وخصائصها بدقة متناهية.'),
    NameOfAllah(
        name: 'البارئ',
        meaning: 'الذي خلق الخلق بتميز وتناسق تام',
        description:
            'الذي يبرز ما قدره الخالق إلى الوجود بأبعاد متناسبة ومتقنة للغاية.'),
    NameOfAllah(
        name: 'المصور',
        meaning: 'معطي كل مخلوق صورته وشكله المتميز',
        description:
            'الذي جعل لكل كائن حياً كان أو جماداً شكلاً خاصاً وهيئة تميزه عن غيره.'),
    NameOfAllah(
        name: 'الغفار',
        meaning: 'الساتر لذنوب عباده المتجاوز عنها',
        description:
            'الذي يستر الذنب في الدنيا ويتجاوز عن العقوبة عليه في الآخرة بكرمه.'),
    NameOfAllah(
        name: 'القهار',
        meaning: 'الغالب لكل الخلائق بقوته وقدرته',
        description:
            'الذي خضعت له الرقاب، وذلت له الجبابرة، وله السلطان المطلق فوق خلقه.'),
    NameOfAllah(
        name: 'الوهاب',
        meaning: 'الكثير العطايا والمنح بلا مقابل',
        description:
            'الذي يجود بنعمه وفضله دون غرض أو سؤال، يعطي من يشاء بما يشاء.'),
    NameOfAllah(
        name: 'الرزاق',
        meaning: 'المتكفل بأرزاق العباد وأقواتهم',
        description:
            'الذي يسوق الأقوات المادية للبدن، والمعنوية الروحية للقلوب والعقول.'),
    NameOfAllah(
        name: 'الفتاح',
        meaning: 'الذي يفتح أبواب الرحمة والرزق والنصر',
        description:
            'الذي يسهل العسير، ويفتح بصائر المؤمنين لمعرفته والوصول إليه.'),
    NameOfAllah(
        name: 'العليم',
        meaning: 'المحيط بكل شيء علماً ظاهراً وباطناً',
        description:
            'الذي لا يخفى عليه مثقال ذرة في الأرض ولا في السماء، يعلم السر وأخفى.'),
    NameOfAllah(
        name: 'القابض',
        meaning: 'الذي يضيق الرزق ويبسطه بحكمته',
        description:
            'الذي يقبض الأرواح عند الموت، ويقبض الرزق عن بعض العباد لمصالحهم.'),
    NameOfAllah(
        name: 'الباسط',
        meaning: 'الذي يوسع الرزق والرحمة بفضله',
        description:
            'الذي يبسط الرزق والرحمة لمن يشاء من عباده، ويبسط يده بالتوبة للخطائين.'),
    NameOfAllah(
        name: 'الخافض',
        meaning: 'الذي يخفض المستكبرين وأهل الكفر',
        description:
            'الذي يخفض الكافرين والأشقياء في الدار الآخرة بذلهم وإبعادهم عن رحمته.'),
    NameOfAllah(
        name: 'الرافع',
        meaning: 'الذي يرفع درجات المؤمنين والصالحين',
        description:
            'الذي يرفع شأن أوليائه في الدنيا بالإيمان، وفي الآخرة بجنات النعيم.'),
    NameOfAllah(
        name: 'المعز',
        meaning: 'الذي يعطي العزة والرفعة لمن أطاعه',
        description:
            'الذي يعز عباده الموحدين بالتوفيق لامتثال أوامره، والظفر في الدارين.'),
    NameOfAllah(
        name: 'المذل',
        meaning: 'الذي يلحق الذل والهوان بالعاصين',
        description:
            'الذي يذل الجبابرة وأعداء الدين بكفرهم، ويذل الأشقياء يوم الحساب.'),
    NameOfAllah(
        name: 'السميع',
        meaning: 'الذي يسمع الأصوات كلها سراً وعلانية',
        description:
            'الذي لا يخفى عليه صوت خافت، ويسمع مناجاة عباده ويجيب دعاءهم.'),
    NameOfAllah(
        name: 'البصير',
        meaning: 'الذي يرى كل المرئيات بدقة بالغة',
        description:
            'الذي يرى حركات النملة السوداء على الصخرة الصماء في الليلة الظلماء.'),
    NameOfAllah(
        name: 'الحكم',
        meaning: 'العادل الذي يفصل بين الخلائق بقضائه',
        description:
            'الذي يحكم بعدله المطلق في الدنيا والآخرة، فلا راد لقضائه ولا معقب لحكمه.'),
    NameOfAllah(
        name: 'العدل',
        meaning: 'الذي لا يجور في قضائه وأفعاله',
        description:
            'المنزه عن الظلم والجور، الذي يعطي كل ذي حق حقه في الخلق والتدبير.'),
    NameOfAllah(
        name: 'اللطيف',
        meaning: 'الرفيق بعباده المحسن إليهم بخفاء',
        description:
            'الذي يعلم دقائق الأمور، ويوصل الخير والنعمة لعباده بطرق خفية ولطيفة.'),
    NameOfAllah(
        name: 'الخبير',
        meaning: 'العالم بخفايا الأمور وبواطنها الدقيقة',
        description:
            'المحيط بحقائق الأشياء وتفاصيلها المخفية التي لا يطلع عليها أحد.'),
    NameOfAllah(
        name: 'الحليم',
        meaning: 'الذي لا يعجل بالعقوبة على العصاة',
        description:
            'الذي يرى معصية العاصين ومخالفتهم فلا يستفزه الغضب، بل يؤخرهم لعلهم يتوبون.'),
    NameOfAllah(
        name: 'العظيم',
        meaning: 'صاحب العظمة والمجد المطلق في ذاته صفاته',
        description:
            'الذي لا تحيط العقول بكيفيته، وهو أجل وأكبر من كل شيء في الوجود.'),
    NameOfAllah(
        name: 'الغفور',
        meaning: 'الكثير المغفرة والستر التام للذنوب',
        description:
            'الذي يغفر الذنب العظيم، ويقبل توبة التائبين مهما كثرت ذنوبهم وتكررت.'),
    NameOfAllah(
        name: 'الشكور',
        meaning: 'الذي يجازي على العمل القليل بالثواب الجزيل',
        description:
            'الذي يثني على المطيعين ويثيبهم ثواباً لا ينقطع لقاء أفعالهم اليسيرة.'),
    NameOfAllah(
        name: 'العلي',
        meaning: 'الذي له العلو المطلق ذو الشأن الرفيع',
        description:
            'المستعلي بذاته وقدره وقدرته فوق جميع خلقه، القاهر لكل المخلوقات.'),
    NameOfAllah(
        name: 'الكبير',
        meaning: 'العظيم ذو الكبرياء والجلال اللامتناهي',
        description:
            'الذي كل شيء دونه صغير، المتفرد بصفات العظمة والخلود والبقاء.'),
    NameOfAllah(
        name: 'الحفيظ',
        meaning: 'الحافظ للكون ولأعمال العباد وحاميهم',
        description:
            'الذي يحفظ السماوات والأرض بأمره، ويحفظ عباده من الهلاك والشرور.'),
    NameOfAllah(
        name: 'المقيت',
        meaning: 'المتكفل بأقوات الخلق والمديم لها',
        description:
            'المقتدر الذي يمد كل مخلوق برزقه وقوته في كل ثانية من حياته.'),
    NameOfAllah(
        name: 'الحسيب',
        meaning: 'الكافي لعباده والمحاسب لهم بعدله',
        description:
            'الذي يكفي عبده كل ما يهمه، وهو المحاسب الشاهد على كل الأعمال.'),
    NameOfAllah(
        name: 'الجليل',
        meaning: 'المتصف بصفات الجلال والعظمة المطلقة',
        description:
            'المستحق لصفات الكمال والجمال، المتميز بالهيبة والقدسية والوقار.'),
    NameOfAllah(
        name: 'الكريم',
        meaning: 'الذي يعطي بلا حساب ويسامح بكرمه',
        description:
            'الذي يبتدئ بالنعم دون سؤال، ويعفو عن الخطايا عند المقدرة والندم.'),
    NameOfAllah(
        name: 'الرقيب',
        meaning: 'الملاحظ الشاهد الحاضر الذي لا يغيب',
        description:
            'الذي يراقب حركات الصدور، ويدرك أفعال الجوارح فلا يغيب عنه ذرة.'),
    NameOfAllah(
        name: 'المجيب',
        meaning: 'الذي يستجيب لدعاء السائلين وطلباتهم',
        description:
            'الذي يقبل تضرع عباده عند الشدة، ويجيب سؤلهم برحمته وحكمته.'),
    NameOfAllah(
        name: 'الواسع',
        meaning: 'الذي وسع كل شيء رحمة وعلماً ورزقاً',
        description:
            'الذي لا يحده حد، المتصف بالسعة والشمول في مغفرته وفضله وخزائنه.'),
    NameOfAllah(
        name: 'الحكيم',
        meaning: 'الذي يضع الأمور في مواضعها الصحيحة',
        description:
            'المنزه عن العبث، المتقن في خلقه وتدبيره، الصائب في تشريعاته.'),
    NameOfAllah(
        name: 'الودود',
        meaning: 'الذي يتودد لعباده بالنعم ويحب أولياءه',
        description:
            'الذي يحب المؤمنين ويرضى عنهم، ويجعل لهم وداً ومحبة في قلوب خلقه.'),
    NameOfAllah(
        name: 'المجيد',
        meaning: 'الشريف ذو المجد والخصال الحميدة',
        description:
            'المتصف بغاية الكرم والشرف والسعة، وله الحمد المطلق في الأولى والآخرة.'),
    NameOfAllah(
        name: 'الباعث',
        meaning: 'الذي يبعث الموتى من القبور للحساب',
        description:
            'الذي يحيي الخلق بعد موتهم للحساب والجزاء، ويبعث رسله لهداية البشر.'),
    NameOfAllah(
        name: 'الشهيد',
        meaning: 'الشاهد الحاضر المطلع على كل غائب',
        description:
            'الذي لا يعزب عنه شيء، المطلع على بواطن النيات وظواهر الأعمال.'),
    NameOfAllah(
        name: 'الحق',
        meaning: 'الثابت الوجود المنزه عن الزوال والباطل',
        description: 'الذي وجوده حق، وقوله حق، ووعده حق، ولقاؤه حق، ودينه حق.'),
    NameOfAllah(
        name: 'الوكيل',
        meaning: 'المتكفل بتدبير أمور خلقه الكافي لهم',
        description:
            'الذي يتوكل عليه المؤمنون في كفاية شؤونهم، الموثوق به في تسيير كل حركة.'),
    NameOfAllah(
        name: 'القوي',
        meaning: 'صاحب القدرة التامة التي لا يعجزها شيء',
        description:
            'الذي له القوة المطلقة والبطش الشديد، لا يعجزه شيء في الأرض ولا في السماء.'),
    NameOfAllah(
        name: 'المتين',
        meaning: 'شديد القوة والصلابة الذي لا يضعف أبداً',
        description:
            'الذي لا يلحقه تعب ولا إعياء في أفعاله، وقوته ثابتة لا تتأثر بالزمن.'),
    NameOfAllah(
        name: 'الولي',
        meaning: 'الناصر والمعين لعباده المؤمنين ومحبهم',
        description:
            'الذي يتولى أمور عباده الصالحين بالنصرة والتوفيق والمحبة والرعاية.'),
    NameOfAllah(
        name: 'الحميد',
        meaning: 'المستحق للحمد والثناء المطلق على الدوام',
        description:
            'المحمود في ذاته وأفعاله وقضائه وتشريعه، الشكور لعباده المطيعين.'),
    NameOfAllah(
        name: 'المحصي',
        meaning: 'الذي يحصي أنفاس الخلق وأعمالهم بدقة',
        description:
            'العالم بتفاصيل الأعداد والمقادير، المحيط بكليات الأشياء وجزئياتها بالكامل.'),
    NameOfAllah(
        name: 'المبدئ',
        meaning: 'الذي بدأ الخلق من عدم بلا مثال سابق',
        description:
            'الذي اخترع الكائنات وأنشأها أول مرة بقدرته المطلقة دون استعانة.'),
    NameOfAllah(
        name: 'المعيد',
        meaning: 'الذي يعيد الخلق إلى الموت ثم البعث',
        description:
            'الذي يرجع الخلق بعد فنائهم إلى الحياة للحساب والخلود في الدارين.'),
    NameOfAllah(
        name: 'المحيي',
        meaning: 'واهب الحياة ومحيي الأجساد البالية',
        description:
            'الذي يحيي العظام وهي رميم، ويحيي القلوب بنور الإيمان والمعرفة.'),
    NameOfAllah(
        name: 'المميت',
        meaning: 'الذي يقبض الأرواح ويميت المخلوقات بحكمته',
        description:
            'الذي كتب الموت والزوال على جميع الخلائق، والمنفرد بالبقاء الدائم.'),
    NameOfAllah(
        name: 'الحي',
        meaning: 'صاحب الحياة الكاملة الدائمة بلا بداية ونهاية',
        description:
            'الذي لا يموت أبداً، الموصوف بالحياة الأزلية الأبدية التي هي أصل كل حياة.'),
    NameOfAllah(
        name: 'القيوم',
        meaning: 'القائم بنفسه والمدبر لشؤون خلقه بالكامل',
        description:
            'الذي لا يزول ولا ينام، القائم برزق وحفظ وتدبير كل نفس مخلوقة.'),
    NameOfAllah(
        name: 'الواجد',
        meaning: 'الذي يجد كل ما يريده بلا تعب ولا وسيلة',
        description:
            'الغني الذي لا يعوزه شيء، الواجد لكل مفقود، والمحيط بكل تفصيلة.'),
    NameOfAllah(
        name: 'الماجد',
        meaning: 'صاحب الشرف والمجد والعطايا الجزيلة',
        description:
            'الذي له الجلال والكمال، والكثير العطاء والفضل المترادف على خلقه.'),
    NameOfAllah(
        name: 'الواحد',
        meaning: 'المتفرد بذاته وصفاته وأفعاله بلا شريك',
        description:
            'الذي لا يتجزأ ولا يشبهه شيء، والمتفرد بالربوبية والألوهية بالكامل.'),
    NameOfAllah(
        name: 'الأحد',
        meaning: 'الفرد الصمد المتفرد بالوحدانية المطلقة',
        description:
            'الذي لم يلد ولم يولد ولم يكن له كفواً أحد، المنزه عن الكثرة والأشباه.'),
    NameOfAllah(
        name: 'الصمد',
        meaning: 'المقصود في الحوائج الذي لا يحتاج لأحد',
        description:
            'الذي تصمد وتتجه إليه الخلائق في قضاء حوائجها، المستغني عن كل أحد.'),
    NameOfAllah(
        name: 'القادر',
        meaning: 'صاحب القدرة على إيجاد وفناء الأشياء',
        description:
            'الذي إنما أمره إذا أراد شيئاً أن يقول له كن فيكون، القادر على كل شيء.'),
    NameOfAllah(
        name: 'المقتدر',
        meaning: 'عظيم القدرة والسيطرة التامة الفعالة',
        description:
            'الذي يظهر قدرته البالغة في خلق الأكوان، المتمكن الذي لا يمتنع عليه شيء.'),
    NameOfAllah(
        name: 'المقدم',
        meaning: 'الذي يقدم الأشخاص والأشياء بحكمته',
        description:
            'الذي يضع الأشياء في مواضعها، ويقدم من يشاء من العباد بتوفيقه ورفعة شأنه.'),
    NameOfAllah(
        name: 'المؤخر',
        meaning: 'الذي يؤخر الأشخاص والأشياء لحكمة بالغة',
        description:
            'الذي يؤخر عقوبة العصاة لعلهم يتوبون، ويضع الأشياء في مواضعها المتأخرة.'),
    NameOfAllah(
        name: 'الأول',
        meaning: 'السابق لكل شيء بلا بداية لوجوده',
        description:
            'الذي ليس قبله شيء، الأزلي الذي كان ولم يكن شيء معه في الكون.'),
    NameOfAllah(
        name: 'الآخر',
        meaning: 'الباقي بعد فناء خلقه بلا نهاية لوجوده',
        description:
            'الذي ليس بعده شيء، الأبدي الدائم الباقي بعد فناء جميع المخلوقات.'),
    NameOfAllah(
        name: 'الظاهر',
        meaning: 'الغالب البين الواضح بأدلته وآياته',
        description:
            'الذي ظهر فوق كل شيء، والمعلوم بآثار قدرته وصنعته الواضحة الباهرة.'),
    NameOfAllah(
        name: 'الباطن',
        meaning: 'الخفي المحتجب عن الحواس المحيط بالبواطن',
        description:
            'الذي لا تراه الأبصار في الدنيا، ويعلم بواطن الضمائر وخفايا النفوس.'),
    NameOfAllah(
        name: 'الوالي',
        meaning: 'المالك المتصرف المدبر لشؤون المخلوقات',
        description:
            'الذي يتولى تدبير شؤون مملكته الكبرى، وينفذ أمره في خلقه بالكامل.'),
    NameOfAllah(
        name: 'المتعالي',
        meaning: 'المنزه عن صفات المخلوقين والبالغ أقصى الرفعة',
        description:
            'المستعلي بجلاله وعظمته عن كذب المفترين، والرفيع في شأنه وقدره.'),
    NameOfAllah(
        name: 'البر',
        meaning: 'المحسن العطوف الشفيق بعباده المتسع العطاء',
        description:
            'الذي يعطف على خلقه بالنعمة، ويجزي المطيعين أضعاف عملهم برحمته.'),
    NameOfAllah(
        name: 'التواب',
        meaning: 'الذي يقبل توبة التائبين ويسهل أسبابها',
        description:
            'الذي يوفق عباده للتوبة ثم يقبلها منهم، ويغسل ذنوبهم بكرمه وسعته.'),
    NameOfAllah(
        name: 'المنتقم',
        meaning: 'المعاقب للعصاة والظالمين بعد الإعذار والإنذار',
        description:
            'الذي يقصم الجبابرة والظالمين بعد إقامة الحجة عليهم بذنوبهم العظيمة.'),
    NameOfAllah(
        name: 'العفو',
        meaning: 'الذي يمحو السيئات ويسقط عقوبتها ورضوان',
        description:
            'الذي يتجاوز عن الخطايا ويمحوها من الصحف بالكلية، وهو أبلغ من الغفور.'),
    NameOfAllah(
        name: 'الرؤوف',
        meaning: 'شديد الرحمة والرأفة بعباده الملطف بهم',
        description:
            'الذي يرأف بعباده المذنبين فيقبل توبتهم، ولا يكلف نفساً إلا وسعها.'),
    NameOfAllah(
        name: 'مالك الملك',
        meaning: 'المتصرف في الأكوان والملكوت كيفما يريد',
        description:
            'الذي ينفذ مشيئته في ملكه وحده دون منازع أو مستشار بالكلية.'),
    NameOfAllah(
        name: 'ذو الجلال والإكرام',
        meaning: 'المستحق للتعظيم والإكرام لصفات كماله',
        description:
            'صاحب العظمة والكبرياء المستحق للحمد، والمكرم لأوليائه بالثواب.'),
    NameOfAllah(
        name: 'المقسط',
        meaning: 'العادل المنصف المظلومين من الظلمة',
        description:
            'الذي يأخذ للمظلوم حقه من الظالم بعدله وحكمته، ويقسم الرزق بالإنصاف.'),
    NameOfAllah(
        name: 'الجامع',
        meaning: 'الذي يجمع الخلائق يوم الحساب ويجمع القلوب',
        description:
            'الذي يجمع الناس في المحشر، ويجمع شتات الأمور، ويجمع قلوب المؤمنين.'),
    NameOfAllah(
        name: 'الغني',
        meaning: 'المستغني عن كل خلقه والكل محتاج إليه',
        description:
            'الذي له الغنى المطلق فلا يحتاج لأحد من خلقه، والكون قائم بمدده بفضله.'),
    NameOfAllah(
        name: 'المغني',
        meaning: 'الذي يغني من يشاء من خلقه بفضله وكرمه',
        description:
            'الذي يمد عباده بالكفاية واليسر والرضا والغنى المادي والمعنوي الروحي.'),
    NameOfAllah(
        name: 'المانع',
        meaning: 'الذي يمنع العطاء والنعمة لحكمة بالغة',
        description:
            'الذي يمنع البلاء عن أوليائه، ويحرم من يشاء من النعم لحكمة بالغة يعلمها وحده.'),
    NameOfAllah(
        name: 'الضار',
        meaning: 'الموجد للضرر ومسلطه لحكمته البالغة',
        description:
            'الذي بيده الضر والنفع وحده، ولا يقع مكروه أو ضر إلا بإذنه وقدره.'),
    NameOfAllah(
        name: 'النافع',
        meaning: 'الموجد للنفع وواهبه لمن يشاء من الخلائق',
        description:
            'الذي يسوق أسباب الخير والمنفعة والبركة في الأبدان والروح والرزق.'),
    NameOfAllah(
        name: 'النور',
        meaning: 'منير الكون والقلوب وواهب البصيرة بالإيمان',
        description:
            'الذي أضاء السماوات والأرض بنوره، وينير قلوب عباده بالهدى والقرآن.'),
    NameOfAllah(
        name: 'الهادي',
        meaning: 'المرشد والموفق للحق والهداية والإيمان',
        description:
            'الذي يهدى الخلائق لسبل العيش والمعاش، ويهدي قلوب المؤمنين لمعرفته وعشق طاعته.'),
    NameOfAllah(
        name: 'البديع',
        meaning: 'الخالق المبتكر للكون بلا مثال أو سابق صانع',
        description:
            'الذي خلق السماوات والأرض بغاية الجمال والإعجاز الهندسي بلا شبيه سابق.'),
    NameOfAllah(
        name: 'الباقي',
        meaning: 'الدائم الوجود المنزه عن الفناء والزوال',
        description:
            'الذي بقاؤه أزلي أبدي، فلا نهاية لوجوده وهو حي لا يموت أبداً.'),
    NameOfAllah(
        name: 'الوارث',
        meaning: 'الذي يرث الأرض ومن عليها بعد فناء الخلائق',
        description:
            'الباقي الدائم بعد زوال الملاك، والذي يرجع إليه ملك كل شيء في النهاية.'),
    NameOfAllah(
        name: 'الرشيد',
        meaning: 'المرشد والموجه والمنزه أفعاله عن السوء',
        description:
            'الذي يرشد الخلق بمصالحه، وتدبيره وحكمته بالغة الصواب والكمال المطلق.'),
    NameOfAllah(
        name: 'الصبور',
        meaning: 'الذي لا يعجل بالعقوبة بل يمهل العصاة بكرمه',
        description:
            'الذي لا يستفزه العصيان فيعاقب فوراً، بل يصبر ويمهل لعل عبده يعود تائباً.'),
  ];

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<AppThemeManager>(context);
    final theme = themeManager.currentTheme;

    final filteredNames = _names.where((item) {
      return item.name.contains(_searchQuery) ||
          item.meaning.contains(_searchQuery) ||
          item.description.contains(_searchQuery);
    }).toList();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.primaryColor,
          elevation: 0,
          title: Text(
            'أسماء الله الحسنى',
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: theme.gradientColors,
            ),
          ),
          child: Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(12.0),
                key: const ValueKey('names_search_padding'),
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.cardColor.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                        color: theme.accentColor.withOpacity(0.3), width: 1),
                  ),
                  child: TextField(
                    style: TextStyle(color: theme.textColor),
                    decoration: InputDecoration(
                      hintText: 'ابحث عن اسم من أسماء الله الحسنى...',
                      hintStyle: GoogleFonts.cairo(
                          color: theme.subtitleColor.withOpacity(0.6)),
                      prefixIcon: Icon(Icons.search, color: theme.accentColor),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                      });
                    },
                  ),
                ),
              ),

              // Grid view of names
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.95,
                  ),
                  itemCount: filteredNames.length,
                  itemBuilder: (context, index) {
                    final nameItem = filteredNames[index];
                    return GestureDetector(
                      onTap: () => _showNameDetails(nameItem, theme),
                      child: Card(
                        color: theme.cardColor,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                          side: BorderSide(
                            color: theme.accentColor.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                theme.cardColor,
                                theme.primaryColor.withOpacity(0.1),
                              ],
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                nameItem.name,
                                style: GoogleFonts.amiri(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: theme.accentColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4.0),
                                child: AutoScrollText(
                                  nameItem.meaning,
                                  style: GoogleFonts.cairo(
                                    fontSize: 10,
                                    color: theme.textColor.withOpacity(0.7),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNameDetails(NameOfAllah nameItem, AppTheme theme) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
              border: Border(
                top: BorderSide(color: theme.accentColor, width: 1.5),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: theme.textColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    nameItem.name,
                    style: GoogleFonts.amiri(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: theme.accentColor,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'المعنى المختصر:',
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    color: theme.accentColor,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  nameItem.meaning,
                  style: GoogleFonts.cairo(
                    color: theme.textColor,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'الشرح والتعبد بالاسم:',
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    color: theme.accentColor,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  nameItem.description,
                  style: GoogleFonts.cairo(
                    color: theme.textColor,
                    fontSize: 14,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () async {
                    final navigator = Navigator.of(context);
                    navigator.pop();
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString('tasbih_dhikr', nameItem.name);
                    
                    navigator.push(
                      MaterialPageRoute(
                        builder: (_) => const TasbihScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.fingerprint_rounded, color: Colors.black),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.accentColor,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  label: Text(
                    'تكرار الذكر بالاسم (تسبيح)',
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    'إغلاق',
                    style: GoogleFonts.cairo(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
