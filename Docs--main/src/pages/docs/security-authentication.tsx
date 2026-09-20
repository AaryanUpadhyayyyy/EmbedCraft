// AUTO-GENERATED page — content for /security/authentication
// Edit freely; this file owns the full content for this route.
import { DocPageShell } from "@/components/docs/DocPageShell";
import type { Block } from "@/types/docs";

const SLUG = "/security/authentication";
const TITLE = "Short Lived Token Authentication";
const DESCRIPTION = "EmbedCraft supports two types of authentication methods for better security: short-lived token authentication and static public key authentication. This document will explain how to use the short-lived token authentication method.";

const BLOCKS: Block[] = [
  {
    "type": "heading",
    "level": 1,
    "text": "Short Lived Token Authentication",
    "id": "short-lived-token-authentication"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "EmbedCraft supports two types of authentication methods for better security: short-lived token authentication and static public key authentication. This document will explain how to use the short-lived token authentication method."
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "This feature is not enabled by default. Please reach out to the EmbedCraft team to enable it."
      }
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Implementation flow overview",
    "id": "implementation-flow-overview"
  },
  {
    "type": "list",
    "ordered": false,
    "items": [
      [
        {
          "t": "t",
          "v": "Your backend will call EmbedCraft's"
        },
        {
          "t": "c",
          "v": "getToken"
        },
        {
          "t": "t",
          "v": "API to fetch this token."
        }
      ]
    ]
  },
  {
    "type": "list",
    "ordered": true,
    "items": [
      [
        {
          "t": "t",
          "v": "The user is authenticated by the frontend application."
        }
      ],
      [
        {
          "t": "t",
          "v": "The frontend will expose an API that returns a short-lived token to the client application based on the user’s authorization."
        }
      ],
      [
        {
          "t": "t",
          "v": "EmbedCraft SDKs provide a function that allows you to register your token API. The following sections explain how to use this function."
        }
      ]
    ]
  },
  {
    "type": "heading",
    "level": 3,
    "text": "Get Token API",
    "id": "get-token-api"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "This API helps retrieve a short-lived token, which is valid for 60 minutes by default. It should be called from your backend, not directly from the frontend."
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Endpoint URL:"
      },
      {
        "t": "c",
        "v": "https://main-api.embedcraft.com/api/clients/jwt/token"
      }
    ]
  },
  {
    "type": "heading",
    "level": 4,
    "text": "Authorization",
    "id": "authorization"
  },
  {
    "type": "table",
    "header": [
      [
        {
          "t": "t",
          "v": "Key"
        }
      ],
      [
        {
          "t": "t",
          "v": "Value"
        }
      ]
    ],
    "rows": [
      [
        [
          {
            "t": "c",
            "v": "apiKey"
          }
        ],
        [
          {
            "t": "c",
            "v": "YOUR_PRIVATE_API_KEY"
          }
        ]
      ]
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "You'll need to generate a"
      },
      {
        "t": "c",
        "v": "PRIVATE_API_KEY"
      },
      {
        "t": "t",
        "v": "from the Settings section in your EmbedCraft dashboard."
      }
    ]
  },
  {
    "type": "heading",
    "level": 4,
    "text": "Query Parameters",
    "id": "query-parameters"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "c",
        "v": "expiryMins"
      },
      {
        "t": "t",
        "v": "(integer): Token expiry in minutes (default: 60 mins)."
      }
    ]
  },
  {
    "type": "heading",
    "level": 4,
    "text": "Response Format",
    "id": "response-format"
  },
  {
    "type": "code",
    "lang": "json",
    "code": "{\t\"token\": \"eyJhbGciOiJFZERTQSIsImtpZCI6IjBjNDk0NDRmLWRjMTAtNDMxYS04NDc0LWIyZTMwMjAyOTNlNiJ9.eyJpYXQiOjE3MzIwMjAyNDMsImV4cCI6MTczMjAyMjA0M30.gB6rKYtkwMe2itS5HWq4lnJyiDA55BIMkqx0cdvv5Z0FQAiYS1kcVkn_i_jgUL8r4WW-4185_ZkEbhK_aALMAQ\"}"
  },
  {
    "type": "heading",
    "level": 4,
    "text": "Response Parameters",
    "id": "response-parameters"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "c",
        "v": "token"
      },
      {
        "t": "t",
        "v": "(string): The short-lived token, which you will use in the"
      },
      {
        "t": "c",
        "v": "refreshToken"
      },
      {
        "t": "t",
        "v": "method on the frontend."
      }
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Frontend Setup",
    "id": "frontend-setup"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "To handle token expiration and refreshing, you need to register a"
      },
      {
        "t": "c",
        "v": "refreshToken"
      },
      {
        "t": "t",
        "v": "method in your frontend. This method will be responsible for fetching a new token when needed."
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Make sure this method is fully functional immediately after the user authenticates, as the token is necessary for all EmbedCraft API calls."
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Ensure that your"
      },
      {
        "t": "c",
        "v": "refreshToken"
      },
      {
        "t": "t",
        "v": "method:"
      }
    ]
  },
  {
    "type": "list",
    "ordered": true,
    "items": [
      [
        {
          "t": "t",
          "v": "Returns a valid short-lived token or"
        },
        {
          "t": "c",
          "v": "null"
        },
        {
          "t": "t",
          "v": "."
        }
      ],
      [
        {
          "t": "t",
          "v": "Retrieves the token from your backend when the SDK calls it."
        }
      ]
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "This ensures that the SDK can call your refreshToken method whenever the token expires, maintaining a valid token for all EmbedCraft API calls."
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Example Implementations:"
      }
    ]
  },
  {
    "type": "list",
    "ordered": false,
    "items": [
      [
        {
          "t": "t",
          "v": "JavaScript"
        }
      ],
      [
        {
          "t": "t",
          "v": "Java"
        }
      ],
      [
        {
          "t": "t",
          "v": "Kotlin"
        }
      ],
      [
        {
          "t": "t",
          "v": "Swift"
        }
      ],
      [
        {
          "t": "t",
          "v": "Flutter"
        }
      ]
    ]
  },
  {
    "type": "code",
    "lang": "js",
    "code": "import axios from 'axios';async function refreshToken() {\tconst res = await axios.get('your_backend_api_end_point', {\t\theaders: {\t\t\tAuthorization: your_token,\t\t},\t});\tif (res.statusCode === 200) return res.data.token;\treturn null;}"
  },
  {
    "type": "code",
    "lang": "kt",
    "code": "import java.io.IOException;import okhttp3.OkHttpClient;import okhttp3.Request;import okhttp3.Response;public class TokenRefresher {private static final OkHttpClient client = new OkHttpClient();    public static String refreshToken() throws IOException {        String url = \"your_backend_api_end_point\";        Request request = new Request.Builder()                .url(url)                .addHeader(\"Authorization\", \"your_token\")                .get()                .build();        try (Response response = client.newCall(request).execute()) {            if (response.isSuccessful() && response.body() != null) {                // Assuming the token is part of the response body as a JSON field \"token\"                // If needed, parse the response as JSON                return response.body().string(); // Replace with JSON parsing if necessary            }        }        return null;    }}"
  },
  {
    "type": "code",
    "lang": "kt",
    "code": "import okhttp3.OkHttpClientimport okhttp3.Requestsuspend fun refreshToken(): String? {    val client = OkHttpClient()    val url = \"your_backend_api_end_point\"    val request = Request.Builder()        .url(url)        .addHeader(\"Authorization\", \"your_token\")        .get()        .build()    client.newCall(request).execute().use { response ->        return if (response.isSuccessful) {            response.body?.string()        } else {            null        }    }}"
  },
  {
    "type": "code",
    "lang": "swift",
    "code": "func refreshToken() -> String? {        guard let url = URL(string: \"your_backend_api_end_point\") else { return nil }        var request = URLRequest(url: url)    request.httpMethod = \"GET\"    request.setValue(\"your_token\", forHTTPHeaderField: \"Authorization\")        // Create a semaphore to make the async call synchronous    let semaphore = DispatchSemaphore(value: 0)    var resultToken: String? = nil        URLSession.shared.dataTask(with: request) { data, response, error in                defer { semaphore.signal() }                if let error = error {            print(\"Token refresh error: \\(error)\")            return        }                guard let httpResponse = response as? HTTPURLResponse,              (200...299).contains(httpResponse.statusCode),              let data = data else {            return        }                resultToken = String(data: data, encoding: .utf8)    }.resume()        // Wait for the network call to complete    _ = semaphore.wait(timeout: .now() + 10) // 10 second timeout        return resultToken}"
  },
  {
    "type": "code",
    "lang": "cpp",
    "code": "import 'package:http/http.dart' as http;Future<String?> refreshToken() async {  final uri = Uri.parse('your_backend_api_end_point');  final headers = {    'Authorization': 'your_token',  };  final response = await http.get(uri, headers: headers);  if (response.statusCode == 200) {    // Assuming response body contains the token as plain text    return response.body;  }  return null;}"
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Registering your refreshToken method in EmbedCraft SDKs",
    "id": "registering-your-refreshtoken-method-in-nudge-sdks"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Once you've set up the"
      },
      {
        "t": "c",
        "v": "refreshToken"
      },
      {
        "t": "t",
        "v": "function, you need to register it with the EmbedCraft SDK to handle token expiration."
      }
    ]
  },
  {
    "type": "list",
    "ordered": false,
    "items": [
      [
        {
          "t": "t",
          "v": "React Native"
        }
      ],
      [
        {
          "t": "t",
          "v": "Kotlin"
        }
      ],
      [
        {
          "t": "t",
          "v": "Swift"
        }
      ],
      [
        {
          "t": "t",
          "v": "Flutter"
        }
      ],
      [
        {
          "t": "t",
          "v": "Web"
        }
      ]
    ]
  },
  {
    "type": "code",
    "lang": "js",
    "code": "EmbedCraft.init({\tapiKey: apiKey,\tdebugMode: true,\tregion: Region.IN,\tnavigatorRef: navigationRef,\tregisterRefreshToken: refreshToken,});"
  },
  {
    "type": "code",
    "lang": "kt",
    "code": "NudgeCore.initialize(  application = this,  apiKey = apiKey,  debugMode = true,  region = Region.IN,  registerRefreshToken = {      refreshToken()  })"
  },
  {
    "type": "code",
    "lang": "swift",
    "code": "nudgeLifecycleManager = NudgeInitialise(  apiKey: \"key\",  region: .IN,  registerRefreshToken: refreshToken)"
  },
  {
    "type": "code",
    "lang": "cpp",
    "code": "nudge = EmbedCraft(  apiKey: apiKey,  debugMode: true,  region: Region.IN,  registerRefreshToken: refreshToken,);"
  },
  {
    "type": "code",
    "lang": "js",
    "code": "  const nudge = new EmbedCraft({    apiKey:\"API_KEY\",    region:\"in\" //or \"us\"    registerRefreshToken : refreshToken  });"
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Key Points",
    "id": "key-points"
  },
  {
    "type": "list",
    "ordered": true,
    "items": [
      [
        {
          "t": "t",
          "v": "Use the"
        },
        {
          "t": "c",
          "v": "getToken"
        },
        {
          "t": "t",
          "v": "API from your backend to retrieve short-lived tokens."
        }
      ],
      [
        {
          "t": "t",
          "v": "Register the"
        },
        {
          "t": "c",
          "v": "refreshToken"
        },
        {
          "t": "t",
          "v": "method in the EmbedCraft SDK to manage token expiration."
        }
      ],
      [
        {
          "t": "t",
          "v": "Ensure your"
        },
        {
          "t": "c",
          "v": "refreshToken"
        },
        {
          "t": "t",
          "v": "method is operational immediately after user authentication."
        }
      ]
    ]
  }
] as Block[];

export default function SecurityAuthenticationPage() {
  return <DocPageShell slug={SLUG} title={TITLE} description={DESCRIPTION} blocks={BLOCKS} />;
}
