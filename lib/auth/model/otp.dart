enum OtpMethod { whatsapp, sms }

class OtpMethodOption {
  final OtpMethod method;
  final String iconPath;
  final String title;
  final String description;

  const OtpMethodOption({
    required this.method,
    required this.iconPath,
    required this.title,
    required this.description,
  });
}

const List<OtpMethodOption> otpMethodOptions = [
  OtpMethodOption(
    method: OtpMethod.whatsapp,
    iconPath: 'assets/images/whatsapp.png',
    title: 'WhatsApp',
    description: 'Kirimkan kode lewat pesan WhatsApp',
  ),
  OtpMethodOption(
    method: OtpMethod.sms,
    iconPath: 'assets/images/message.png',
    title: 'SMS',
    description: 'Kirimkan kode lewat pesan SMS',
  ),
];