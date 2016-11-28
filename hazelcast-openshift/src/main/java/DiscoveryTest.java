import com.hazelcast.client.HazelcastClient;
import com.hazelcast.core.Hazelcast;
import com.hazelcast.core.HazelcastInstance;

public class DiscoveryTest {

    public static void main(String[] args) {
        String type = System.getenv("HAZELCAST_TYPE");
        if ("client".equals(type)) {
            HazelcastClient.newHazelcastClient();
        } else {
            Hazelcast.newHazelcastInstance();
        }
    }

}
