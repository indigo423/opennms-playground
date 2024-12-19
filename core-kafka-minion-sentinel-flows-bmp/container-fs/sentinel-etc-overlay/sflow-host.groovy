import static org.opennms.netmgt.telemetry.protocols.common.utils.BsonUtils.get
import static org.opennms.netmgt.telemetry.protocols.common.utils.BsonUtils.getDouble
import static org.opennms.netmgt.telemetry.protocols.common.utils.BsonUtils.getInt64
import org.opennms.netmgt.collection.support.builder.NodeLevelResource

NodeLevelResource nodeLevelResource = new NodeLevelResource(agent.getNodeId())

get(msg, "counters", "0:2003").ifPresent { doc ->
    builder.withGauge(nodeLevelResource, "host-cpu", "load_avg_1min", getDouble(doc, "load_one").get())
    builder.withGauge(nodeLevelResource, "host-cpu", "load_avg_5min", getDouble(doc, "load_five").get())
    builder.withGauge(nodeLevelResource, "host-cpu", "load_avg_15min", getDouble(doc, "load_fifteen").get())
}

get(msg, "counters", "0:2004").ifPresent { doc ->
    builder.withGauge(nodeLevelResource, "host-memory", "mem_total", getInt64(doc, "mem_total").get())
    builder.withGauge(nodeLevelResource, "host-memory", "mem_free", getInt64(doc, "mem_free").get())
    builder.withGauge(nodeLevelResource, "host-memory", "mem_shared", getInt64(doc, "mem_shared").get())
    builder.withGauge(nodeLevelResource, "host-memory", "mem_buffers", getInt64(doc, "mem_buffers").get())
    builder.withGauge(nodeLevelResource, "host-memory", "mem_cached", getInt64(doc, "mem_cached").get())
}
