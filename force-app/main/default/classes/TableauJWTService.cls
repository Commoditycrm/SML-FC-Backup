@RestResource(urlMapping='/tableau/*')
global class TableauJWTService {
    
	@HttpPost
    global static String generateJWT(String tableauUser) {

        if(String.isBlank(tableauUser)) {
            throw new IllegalArgumentException('Tableau user must be provided');
        }
        String clientId = 'f3849c2a-17ce-4b63-b269-acc13c28bc06';
        String secretId = 'c54514aa-62da-45f9-98c2-e8bb97becd0c';
        String secretValue = 'Ri8k88xTD8+iH1Zod78uxiPmEv8gbvBUcqI8CeOEVg4=';

        Long nowSeconds = DateTime.now().getTime() / 1000;

        Map<String, Object> payload = new Map<String, Object>{
            'iss' => clientId,
            'sub' => tableauUser,
            'aud' => 'tableau',
            'exp' => nowSeconds + 300,
            'jti' => String.valueOf(Crypto.getRandomLong()),
            'scp' => new List<String>{ 'tableau:views:embed' }
        };

        String header = JSON.serialize(new Map<String, Object>{
            'alg' => 'HS256',
            'typ' => 'JWT',
            'kid' => secretId
        });

        String body = JSON.serialize(payload);

        String encodedHeader = base64UrlEncode(Blob.valueOf(header));
     String encodedBody = base64UrlEncode(Blob.valueOf(body));

        String unsignedToken =
            encodedHeader + '.' + encodedBody;

        Blob signature = Crypto.generateMac(
            'HmacSHA256',
            Blob.valueOf(unsignedToken),
            Blob.valueOf(secretValue)
        );

        String encodedSignature = base64UrlEncode(signature);


        return unsignedToken + '.' + encodedSignature;
    }
    private static String base64UrlEncode(Blob input) {
    String output = EncodingUtil.base64Encode(input);
    output = output.replace('+', '-');
    output = output.replace('/', '_');
    output = output.replace('=', '');
    return output;
}
}